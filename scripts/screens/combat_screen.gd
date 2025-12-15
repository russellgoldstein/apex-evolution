extends Control
## Main combat screen

const CreatureSlotScene = preload("res://scenes/combat/creature_slot.tscn")
const EnemySlotScene = preload("res://scenes/combat/enemy_slot.tscn")

## UI References
@onready var enemy_container: HBoxContainer = $VBoxContainer/EnemyArea/EnemyContainer
@onready var creature_container: HBoxContainer = $VBoxContainer/BattlefieldArea/CreatureContainer
@onready var card_hand: CardHand = $VBoxContainer/HandArea/CardHand
@onready var end_turn_button: Button = $VBoxContainer/InfoBar/EndTurnButton
@onready var energy_label: Label = $VBoxContainer/InfoBar/EnergyLabel
@onready var hp_label: Label = $VBoxContainer/InfoBar/HPLabel
@onready var food_label: Label = $VBoxContainer/InfoBar/FoodLabel
@onready var turn_indicator: Label = $VBoxContainer/InfoBar/TurnIndicator
@onready var targeting_overlay: ColorRect = $TargetingOverlay
@onready var targeting_hint: Label = $TargetingOverlay/TargetingHint

## Combat manager
var combat_manager: CombatManager

## Slot references
var creature_slots: Array[CreatureSlot] = []
var enemy_slots: Array[EnemySlot] = []

func _ready() -> void:
	# Create combat manager
	combat_manager = CombatManager.new()
	add_child(combat_manager)

	# Connect combat manager signals
	combat_manager.combat_started.connect(_on_combat_started)
	combat_manager.turn_started.connect(_on_turn_started)
	combat_manager.turn_ended.connect(_on_turn_ended)
	combat_manager.combat_ended.connect(_on_combat_ended)
	combat_manager.card_played.connect(_on_card_played)
	combat_manager.damage_dealt.connect(_on_damage_dealt)
	combat_manager.creature_died.connect(_on_creature_died)
	combat_manager.enemy_died.connect(_on_enemy_died)
	combat_manager.targeting_started.connect(_on_targeting_started)
	combat_manager.targeting_cancelled.connect(_on_targeting_cancelled)
	combat_manager.energy_changed.connect(_on_energy_changed)

	# Connect UI signals
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	card_hand.card_clicked.connect(_on_card_clicked)
	card_hand.card_drag_ended.connect(_on_card_drag_ended)

	# Connect run data signals
	RunData.player_hp_changed.connect(_on_player_hp_changed)
	RunData.food_tokens_changed.connect(_on_food_tokens_changed)

	# Hide targeting overlay
	targeting_overlay.visible = false

	# Start combat with enemies from RunData
	_start_combat()

func _start_combat() -> void:
	# Get enemies from RunData
	var enemy_data = RunData.current_enemies
	if enemy_data.is_empty():
		# Create default enemies for testing
		enemy_data = _create_test_enemies()

	combat_manager.start_combat(enemy_data)

func _create_test_enemies() -> Array[EnemyData]:
	var enemies: Array[EnemyData] = []

	# Create a basic scavenger enemy
	var scavenger = EnemyData.new()
	scavenger.id = "scavenger"
	scavenger.enemy_name = "Scavenger"
	scavenger.max_hp = 15
	scavenger.placeholder_color = Color(0.6, 0.3, 0.2)
	scavenger.food_token_reward_min = 15
	scavenger.food_token_reward_max = 20

	# Intent pattern
	var attack_intent = IntentData.new()
	attack_intent.intent_type = Enums.IntentType.ATTACK
	attack_intent.value = 6

	var defend_intent = IntentData.new()
	defend_intent.intent_type = Enums.IntentType.DEFEND
	defend_intent.value = 5

	scavenger.intent_pattern = [attack_intent, attack_intent, defend_intent]

	enemies.append(scavenger)

	# Add second enemy
	var snake = EnemyData.new()
	snake.id = "venomous_snake"
	snake.enemy_name = "Venomous Snake"
	snake.max_hp = 12
	snake.placeholder_color = Color(0.3, 0.5, 0.3)
	snake.food_token_reward_min = 12
	snake.food_token_reward_max = 18

	var poison_attack = IntentData.new()
	poison_attack.intent_type = Enums.IntentType.ATTACK
	poison_attack.value = 4
	poison_attack.applies_status = Enums.StatusType.POISON
	poison_attack.status_amount = 3

	var strong_attack = IntentData.new()
	strong_attack.intent_type = Enums.IntentType.ATTACK
	strong_attack.value = 8

	snake.intent_pattern = [poison_attack, strong_attack]

	enemies.append(snake)

	return enemies

func _on_combat_started() -> void:
	_update_all_displays()

func _on_turn_started(is_player_turn: bool) -> void:
	end_turn_button.disabled = not is_player_turn

	if is_player_turn:
		turn_indicator.text = "Your Turn"
		turn_indicator.add_theme_color_override("font_color", Color(0.3, 0.9, 0.3))
	else:
		turn_indicator.text = "Enemy Turn"
		turn_indicator.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))

	_update_all_displays()

func _on_turn_ended(_is_player_turn: bool) -> void:
	_update_all_displays()

func _on_combat_ended(victory: bool) -> void:
	if victory:
		AudioManager.play_victory()
		# Small delay before going to reward screen
		await get_tree().create_timer(1.0).timeout
		GameManager.combat_victory()
	else:
		AudioManager.play_defeat()
		await get_tree().create_timer(1.0).timeout
		GameManager.combat_defeat()

func _on_card_played(card: CardInstance, _targets: Array) -> void:
	AudioManager.play_card_play()

	# Remove card from hand UI
	var card_ui = card_hand.get_card_ui_for_instance(card)
	if card_ui:
		card_hand.remove_card(card_ui)

	_update_all_displays()

func _on_damage_dealt(source: Variant, target: Variant, amount: int) -> void:
	if amount <= 0:
		return

	AudioManager.play_damage()

	# Flash the target
	if target is CreatureInstance:
		var slot = _get_creature_slot(target)
		if slot:
			slot.flash_damage()
	elif target is EnemyInstance:
		var slot = _get_enemy_slot(target)
		if slot:
			slot.flash_damage()

	# Update displays
	_update_all_displays()

func _on_creature_died(creature: CreatureInstance) -> void:
	AudioManager.play_creature_death()
	_update_creature_slots()

func _on_enemy_died(enemy: EnemyInstance) -> void:
	AudioManager.play_enemy_death()
	_update_enemy_slots()

func _on_targeting_started(card: CardInstance) -> void:
	targeting_overlay.visible = true

	var action = card.get_action_data()
	if action:
		match action.target_type:
			Enums.TargetType.FRIENDLY_CREATURE:
				targeting_hint.text = "Select a creature"
				_highlight_creatures(true)
			Enums.TargetType.ENEMY:
				targeting_hint.text = "Select an enemy"
				_highlight_enemies(true)
			Enums.TargetType.ALL_ENEMIES:
				targeting_hint.text = "Target: All enemies"
				_highlight_enemies(true)

func _on_targeting_cancelled() -> void:
	targeting_overlay.visible = false
	_highlight_creatures(false)
	_highlight_enemies(false)

func _on_energy_changed(current: int, maximum: int) -> void:
	energy_label.text = "Energy: %d/%d" % [current, maximum]

func _on_player_hp_changed(new_hp: int, max_hp: int) -> void:
	hp_label.text = "HP: %d/%d" % [new_hp, max_hp]

func _on_food_tokens_changed(amount: int) -> void:
	food_label.text = "FT: %d" % amount

func _on_end_turn_pressed() -> void:
	combat_manager.end_player_turn()

func _on_card_clicked(card_ui: CardUI) -> void:
	if not combat_manager.is_player_turn:
		return

	var card = card_ui.card_instance
	if not card:
		return

	# Check if card needs targeting
	if card.is_creature_card():
		# Creature cards don't need targeting
		combat_manager.play_card(card, [])
	else:
		var action = card.get_action_data()
		if action and action.target_type != Enums.TargetType.NONE:
			# Need targeting
			if action.requires_creature and combat_manager.player_creatures.is_empty():
				return  # Can't play without creatures
			combat_manager.start_targeting(card)
		else:
			# No targeting needed (like draw cards)
			combat_manager.play_card(card, [])

func _on_card_drag_ended(card_ui: CardUI) -> void:
	# Check if card was dropped on a valid target
	var card = card_ui.card_instance
	if not card:
		return

	# For simplicity, use click-based targeting instead of drag
	# The card will return to hand
	pass

func _on_creature_slot_clicked(slot: CreatureSlot) -> void:
	if combat_manager.is_targeting:
		if slot.creature in combat_manager.valid_targets:
			combat_manager.select_target(slot.creature)
			targeting_overlay.visible = false
			_highlight_creatures(false)

func _on_enemy_slot_clicked(slot: EnemySlot) -> void:
	if combat_manager.is_targeting:
		if slot.enemy in combat_manager.valid_targets:
			combat_manager.select_target(slot.enemy)
			targeting_overlay.visible = false
			_highlight_enemies(false)

func _highlight_creatures(highlight: bool) -> void:
	for slot in creature_slots:
		if highlight and slot.creature in combat_manager.valid_targets:
			slot.set_valid_target(true)
		else:
			slot.set_valid_target(false)

func _highlight_enemies(highlight: bool) -> void:
	for slot in enemy_slots:
		if highlight and slot.enemy in combat_manager.valid_targets:
			slot.set_valid_target(true)
		else:
			slot.set_valid_target(false)

func _update_all_displays() -> void:
	_update_creature_slots()
	_update_enemy_slots()
	_update_hand()
	_update_info_bar()

func _update_creature_slots() -> void:
	# Clear existing slots
	for slot in creature_slots:
		slot.queue_free()
	creature_slots.clear()

	# Create slots for each creature on board
	for creature in combat_manager.player_creatures:
		if creature.is_alive():
			var slot = CreatureSlotScene.instantiate() as CreatureSlot
			creature_container.add_child(slot)
			slot.setup(creature)
			slot.clicked.connect(_on_creature_slot_clicked)
			creature_slots.append(slot)

func _update_enemy_slots() -> void:
	# Clear existing slots
	for slot in enemy_slots:
		slot.queue_free()
	enemy_slots.clear()

	# Create slots for each living enemy
	for enemy in combat_manager.enemies:
		if enemy.is_alive():
			var slot = EnemySlotScene.instantiate() as EnemySlot
			enemy_container.add_child(slot)
			slot.setup(enemy)
			slot.clicked.connect(_on_enemy_slot_clicked)
			enemy_slots.append(slot)

func _update_hand() -> void:
	card_hand.update_hand(RunData.hand, combat_manager)

func _update_info_bar() -> void:
	energy_label.text = "Energy: %d/%d" % [RunData.energy, RunData.max_energy]
	hp_label.text = "HP: %d/%d" % [RunData.player_hp, RunData.player_max_hp]
	food_label.text = "FT: %d" % RunData.food_tokens

func _get_creature_slot(creature: CreatureInstance) -> CreatureSlot:
	for slot in creature_slots:
		if slot.creature == creature:
			return slot
	return null

func _get_enemy_slot(enemy: EnemyInstance) -> EnemySlot:
	for slot in enemy_slots:
		if slot.enemy == enemy:
			return slot
	return null

func _input(event: InputEvent) -> void:
	# Cancel targeting on right click or escape
	if combat_manager.is_targeting:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				combat_manager.cancel_targeting()
		elif event is InputEventKey:
			if event.keycode == KEY_ESCAPE and event.pressed:
				combat_manager.cancel_targeting()
