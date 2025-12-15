extends Node
class_name CombatManager
## Manages all combat logic

signal combat_started
signal turn_started(is_player_turn: bool)
signal turn_ended(is_player_turn: bool)
signal combat_ended(victory: bool)
signal card_played(card: CardInstance, targets: Array)
signal damage_dealt(source: Variant, target: Variant, amount: int)
signal creature_died(creature: CreatureInstance)
signal enemy_died(enemy: EnemyInstance)
signal targeting_started(card: CardInstance)
signal targeting_cancelled
signal energy_changed(current: int, maximum: int)

## Combat state
var is_combat_active: bool = false
var current_phase: Enums.CombatPhase = Enums.CombatPhase.COMBAT_START
var is_player_turn: bool = true

## Combatants
var player_creatures: Array[CreatureInstance] = []  ## Creatures on the board
var enemies: Array[EnemyInstance] = []

## Targeting
var is_targeting: bool = false
var targeting_card: CardInstance
var valid_targets: Array = []

## Constants
const MAX_CREATURES_ON_BOARD = 3
const STARTING_HAND_SIZE = 5
const CARDS_PER_TURN = 5

## Reference to UI (set by combat screen)
var combat_ui: Node

func start_combat(enemy_data_list: Array[EnemyData]) -> void:
	is_combat_active = true
	current_phase = Enums.CombatPhase.COMBAT_START

	# Clear previous state
	player_creatures.clear()
	enemies.clear()

	# Create enemy instances
	for i in range(enemy_data_list.size()):
		var enemy = EnemyInstance.new(enemy_data_list[i])
		enemy.position = i
		enemies.append(enemy)

	# Setup run data for combat
	RunData.setup_combat(enemy_data_list)
	RunData.shuffle_draw_pile()

	# Place lead creature in Lair
	var lead = RunData.get_lead_creature()
	if lead:
		lead.board_position = 0
		player_creatures.append(lead)

	# Draw opening hand
	_draw_opening_hand()

	combat_started.emit()

	# Start first player turn
	await get_tree().create_timer(0.5).timeout
	_start_player_turn()

func _draw_opening_hand() -> void:
	# Check for innate cards first
	var innate_cards: Array[CardInstance] = []
	var other_cards: Array[CardInstance] = []

	for card in RunData.draw_pile:
		if card.has_keyword(Enums.CardKeyword.INNATE):
			innate_cards.append(card)
		else:
			other_cards.append(card)

	# Draw innate cards first
	for card in innate_cards:
		RunData.draw_pile.erase(card)
		RunData.hand.append(card)

	# Then draw rest of hand
	var remaining = STARTING_HAND_SIZE - RunData.hand.size()
	RunData.draw_cards(remaining)

func _start_player_turn() -> void:
	current_phase = Enums.CombatPhase.PLAYER_TURN_START
	is_player_turn = true

	# Restore energy
	RunData.restore_energy()
	energy_changed.emit(RunData.energy, RunData.max_energy)

	# Process start of turn effects
	for creature in player_creatures:
		if creature.is_alive():
			creature.process_turn_start()

	# Trigger traits
	_trigger_traits(TraitData.TraitTrigger.ON_TURN_START)

	# Draw cards
	RunData.draw_cards(CARDS_PER_TURN - RunData.hand.size())

	current_phase = Enums.CombatPhase.PLAYER_ACTION
	turn_started.emit(true)

func end_player_turn() -> void:
	if not is_player_turn or current_phase != Enums.CombatPhase.PLAYER_ACTION:
		return

	current_phase = Enums.CombatPhase.PLAYER_TURN_END

	# Cancel any targeting
	if is_targeting:
		cancel_targeting()

	# Process end of turn effects for creatures
	for creature in player_creatures:
		if creature.is_alive():
			creature.process_turn_end()

	# Discard hand (respects retain keyword)
	RunData.discard_hand()

	# Trigger traits
	_trigger_traits(TraitData.TraitTrigger.ON_TURN_END)

	turn_ended.emit(true)

	# Check for combat end
	if _check_combat_end():
		return

	# Start enemy turn
	await get_tree().create_timer(0.3).timeout
	_start_enemy_turn()

func _start_enemy_turn() -> void:
	current_phase = Enums.CombatPhase.ENEMY_TURN
	is_player_turn = false
	turn_started.emit(false)

	# Process each enemy's action
	for enemy in enemies:
		if not enemy.is_alive():
			continue

		await get_tree().create_timer(0.5).timeout

		if enemy.is_stunned():
			enemy.set_status(Enums.StatusType.STUNNED, 0)
			continue

		await _execute_enemy_intent(enemy)

		# Check if player died
		if RunData.is_player_dead():
			_end_combat(false)
			return

	# Process end of turn for enemies
	for enemy in enemies:
		if enemy.is_alive():
			enemy.process_turn_end()

	turn_ended.emit(false)

	# Check for combat end
	if _check_combat_end():
		return

	# Start next player turn
	await get_tree().create_timer(0.3).timeout
	_start_player_turn()

func _execute_enemy_intent(enemy: EnemyInstance) -> void:
	var intent = enemy.current_intent
	if not intent:
		return

	match intent.intent_type:
		Enums.IntentType.ATTACK:
			await _enemy_attack(enemy, intent)
		Enums.IntentType.DEFEND:
			enemy.set_status(Enums.StatusType.SHIELD, enemy.get_status_amount(Enums.StatusType.SHIELD) + intent.value)
		Enums.IntentType.BUFF:
			enemy.modify_status(Enums.StatusType.STRENGTH, intent.value)
		Enums.IntentType.DEBUFF:
			# Apply debuff to player creatures
			for creature in player_creatures:
				if creature.is_alive():
					creature.modify_status(Enums.StatusType.WEAKNESS, intent.status_amount)
		Enums.IntentType.SUMMON:
			# TODO: Implement summoning
			pass

func _enemy_attack(enemy: EnemyInstance, intent: IntentData) -> void:
	var damage = enemy.get_attack_damage()

	for hit in range(intent.hits):
		if intent.is_aoe:
			# Hit all creatures
			for creature in player_creatures:
				if creature.is_alive():
					var actual_damage = creature.take_damage(damage)
					damage_dealt.emit(enemy, creature, actual_damage)
					if not creature.is_alive():
						_handle_creature_death(creature)
			# Also hit player if piercing or no creatures
			if enemy.has_piercing() or player_creatures.is_empty():
				RunData.take_player_damage(damage)
				damage_dealt.emit(enemy, null, damage)
		else:
			# Single target attack
			if enemy.has_piercing():
				# Hit player directly
				RunData.take_player_damage(damage)
				damage_dealt.emit(enemy, null, damage)
			else:
				# Hit leftmost creature, or player if none
				var target = _get_leftmost_creature()
				if target:
					var actual_damage = target.take_damage(damage)
					damage_dealt.emit(enemy, target, actual_damage)
					if not target.is_alive():
						_handle_creature_death(target)
				else:
					RunData.take_player_damage(damage)
					damage_dealt.emit(enemy, null, damage)

		await get_tree().create_timer(0.2).timeout

func _get_leftmost_creature() -> CreatureInstance:
	for creature in player_creatures:
		if creature.is_alive():
			return creature
	return null

## Card playing

func can_play_card(card: CardInstance) -> bool:
	if not is_player_turn or current_phase != Enums.CombatPhase.PLAYER_ACTION:
		return false

	if is_targeting:
		return false

	var has_creatures = player_creatures.size() > 0
	return card.can_be_played(RunData.energy, has_creatures)

func play_card(card: CardInstance, targets: Array = []) -> void:
	if not can_play_card(card):
		return

	# Spend energy
	if not RunData.spend_energy(card.get_energy_cost()):
		return

	energy_changed.emit(RunData.energy, RunData.max_energy)

	# Remove from hand
	RunData.hand.erase(card)

	# Record stat
	RunData.record_card_played()

	# Trigger traits
	_trigger_traits(TraitData.TraitTrigger.ON_CARD_PLAY)

	# Handle creature cards
	if card.is_creature_card():
		_play_creature_card(card)
	else:
		_play_action_card(card, targets)

	card_played.emit(card, targets)

	# Discard or exhaust
	if card.has_keyword(Enums.CardKeyword.EXHAUST):
		RunData.exhaust_card(card)
	elif card.is_action_card():
		RunData.discard_pile.append(card)

	# Check for combat end
	_check_combat_end()

func _play_creature_card(card: CardInstance) -> void:
	if player_creatures.size() >= MAX_CREATURES_ON_BOARD:
		return

	var creature = card.creature_instance
	if creature and not creature.is_exhausted:
		creature.board_position = player_creatures.size()
		if creature not in player_creatures:
			player_creatures.append(creature)

		_trigger_traits(TraitData.TraitTrigger.ON_CREATURE_PLAY)

func _play_action_card(card: CardInstance, targets: Array) -> void:
	var action = card.get_action_data()
	if not action:
		return

	_trigger_traits(TraitData.TraitTrigger.ON_ACTION_PLAY)

	# Resolve effects
	for effect in action.effects:
		_resolve_effect(effect, card, targets)

func _resolve_effect(effect: EffectData, card: CardInstance, targets: Array) -> void:
	var value = effect.value

	match effect.type:
		Enums.EffectType.DAMAGE:
			for target in targets:
				var damage = value
				# If targeting friendly creature, it attacks enemies
				if target is CreatureInstance:
					damage = target.get_attack_damage() + value - target.current_attack
					# Find enemy target (first alive enemy)
					for enemy in enemies:
						if enemy.is_alive():
							var actual = enemy.take_damage(damage)
							damage_dealt.emit(target, enemy, actual)
							RunData.record_damage(actual)
							if not enemy.is_alive():
								_handle_enemy_death(enemy)
							break
				elif target is EnemyInstance:
					var actual = target.take_damage(damage)
					damage_dealt.emit(card, target, actual)
					RunData.record_damage(actual)
					if not target.is_alive():
						_handle_enemy_death(target)

		Enums.EffectType.SHIELD:
			for target in targets:
				if target is CreatureInstance:
					target.modify_status(Enums.StatusType.SHIELD, value)

		Enums.EffectType.ARMOR:
			for target in targets:
				if target is CreatureInstance:
					target.modify_status(Enums.StatusType.ARMOR, value)

		Enums.EffectType.HEAL:
			for target in targets:
				if target is CreatureInstance:
					target.heal(value)

		Enums.EffectType.DRAW:
			RunData.draw_cards(value)

		Enums.EffectType.ENERGY:
			RunData.gain_energy(value)
			energy_changed.emit(RunData.energy, RunData.max_energy)

		Enums.EffectType.POISON:
			for target in targets:
				if target is EnemyInstance:
					target.modify_status(Enums.StatusType.POISON, value)
				elif target is CreatureInstance:
					target.modify_status(Enums.StatusType.POISON, value)

		Enums.EffectType.STRENGTH:
			for target in targets:
				if target is CreatureInstance:
					target.modify_status(Enums.StatusType.STRENGTH, value)

		Enums.EffectType.WEAKNESS:
			for target in targets:
				if target is EnemyInstance:
					target.modify_status(Enums.StatusType.WEAKNESS, value)

## Targeting

func start_targeting(card: CardInstance) -> void:
	targeting_card = card
	is_targeting = true
	valid_targets = _get_valid_targets(card)
	targeting_started.emit(card)

func cancel_targeting() -> void:
	is_targeting = false
	targeting_card = null
	valid_targets.clear()
	targeting_cancelled.emit()

func select_target(target: Variant) -> void:
	if not is_targeting or not targeting_card:
		return

	if target in valid_targets:
		play_card(targeting_card, [target])
		is_targeting = false
		targeting_card = null
		valid_targets.clear()

func _get_valid_targets(card: CardInstance) -> Array:
	var targets: Array = []

	if card.is_creature_card():
		return targets  # Creatures don't need targeting

	var action = card.get_action_data()
	if not action:
		return targets

	match action.target_type:
		Enums.TargetType.FRIENDLY_CREATURE:
			for creature in player_creatures:
				if creature.is_alive():
					targets.append(creature)
		Enums.TargetType.ENEMY:
			for enemy in enemies:
				if enemy.is_alive():
					targets.append(enemy)
		Enums.TargetType.ALL_ENEMIES:
			for enemy in enemies:
				if enemy.is_alive():
					targets.append(enemy)
		Enums.TargetType.ALL_CREATURES:
			for creature in player_creatures:
				if creature.is_alive():
					targets.append(creature)
		Enums.TargetType.NONE:
			# No targeting needed, return empty (will use empty target list)
			pass

	return targets

## Death handling

func _handle_creature_death(creature: CreatureInstance) -> void:
	creature.die()
	player_creatures.erase(creature)
	creature_died.emit(creature)

	_trigger_traits(TraitData.TraitTrigger.ON_CREATURE_DEATH)

func _handle_enemy_death(enemy: EnemyInstance) -> void:
	enemies.erase(enemy)
	enemy_died.emit(enemy)

	_trigger_traits(TraitData.TraitTrigger.ON_ENEMY_DEATH)

## Combat end

func _check_combat_end() -> bool:
	# Check if all enemies are dead
	var all_enemies_dead = true
	for enemy in enemies:
		if enemy.is_alive():
			all_enemies_dead = false
			break

	if all_enemies_dead:
		_end_combat(true)
		return true

	# Check if player is dead
	if RunData.is_player_dead():
		_end_combat(false)
		return true

	return false

func _end_combat(victory: bool) -> void:
	current_phase = Enums.CombatPhase.COMBAT_END
	is_combat_active = false

	if victory:
		RunData.record_combat_won()

		# Calculate rewards
		var total_food = 0
		for enemy in enemies:
			total_food += enemy.data.get_random_reward()
		RunData.add_food_tokens(total_food)

	combat_ended.emit(victory)

## Traits

func _trigger_traits(trigger: TraitData.TraitTrigger) -> void:
	var matching_traits = RunData.get_traits_by_trigger(trigger)
	for trait_data in matching_traits:
		_apply_trait_effect(trait_data)

func _apply_trait_effect(trait_data: TraitData) -> void:
	# TODO: Implement trait effects based on effect_params
	match trait_data.id:
		"compound_eyes":
			# Scry 2 - look at top 2 cards (simplified: just draw 1 extra)
			pass
		"bloodlust":
			# Give all creatures +1 strength
			for creature in player_creatures:
				creature.modify_status(Enums.StatusType.STRENGTH, 1)
		"thick_scales":
			# Give lead creature 3 armor
			if player_creatures.size() > 0:
				player_creatures[0].modify_status(Enums.StatusType.ARMOR, 3)
