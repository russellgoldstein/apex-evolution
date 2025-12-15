extends Node
## RunData - Holds all state for the current run

# Preload classes to ensure they're available
const CardInstanceClass = preload("res://scripts/cards/card_instance.gd")
const CreatureInstanceClass = preload("res://scripts/combat/creature_instance.gd")
const TraitDataClass = preload("res://scripts/resources/trait_data.gd")
const MapDataClass = preload("res://scripts/resources/map_data.gd")
const EnemyDataClass = preload("res://scripts/resources/enemy_data.gd")
const ArchetypeDataClass = preload("res://scripts/resources/archetype_data.gd")
const CreatureCardDataClass = preload("res://scripts/resources/creature_card_data.gd")
const CardDataClass = preload("res://scripts/resources/card_data.gd")

signal player_hp_changed(new_hp: int, max_hp: int)
signal food_tokens_changed(new_amount: int)
signal energy_changed(new_energy: int, max_energy: int)
signal deck_changed
signal creature_added(creature)
signal creature_removed(creature)
signal trait_acquired(trait_data)

## Player stats
var player_hp: int = 50
var player_max_hp: int = 50
var food_tokens: int = 0

## Energy (combat resource)
var energy: int = 3
var max_energy: int = 3

## Deck
var deck: Array = []
var draw_pile: Array = []
var hand: Array = []
var discard_pile: Array = []
var exhaust_pile: Array = []

## Creatures (persistent between combats)
var creatures: Array = []
var lead_creature_index: int = 0

## Traits
var traits: Array = []

## Map progress
var current_act: int = 1
var current_map = null
var maps: Array = []  # One per act

## Combat state (set before entering combat)
var current_enemies: Array = []

## Archetype used this run
var current_archetype = null

## Stats for end screen
var total_damage_dealt: int = 0
var total_cards_played: int = 0
var combats_won: int = 0

func _ready() -> void:
	pass

## Run initialization

func start_new_run() -> void:
	## Clear everything for a fresh run
	clear_run()

func clear_run() -> void:
	player_hp = 50
	player_max_hp = 50
	food_tokens = 0
	energy = 3
	max_energy = 3

	deck.clear()
	draw_pile.clear()
	hand.clear()
	discard_pile.clear()
	exhaust_pile.clear()

	creatures.clear()
	lead_creature_index = 0

	traits.clear()

	current_act = 1
	current_map = null
	maps.clear()

	current_enemies.clear()
	current_archetype = null

	total_damage_dealt = 0
	total_cards_played = 0
	combats_won = 0

func initialize_with_archetype(archetype) -> void:
	current_archetype = archetype

	# Create starting creature instance
	var creature = CreatureInstanceClass.new(archetype.starting_creature)
	creatures.append(creature)
	lead_creature_index = 0

	# Create creature card and add to deck
	var creature_card = CardInstanceClass.new(archetype.starting_creature)
	creature_card.creature_instance = creature
	deck.append(creature_card)

	# Add starting action cards
	for action_data in archetype.starting_deck:
		var card = CardInstanceClass.new(action_data)
		deck.append(card)

	# Add starting trait
	if archetype.starting_trait:
		traits.append(archetype.starting_trait)
		trait_acquired.emit(archetype.starting_trait)

	deck_changed.emit()

## Player HP

func take_player_damage(amount: int) -> void:
	player_hp = maxi(0, player_hp - amount)
	player_hp_changed.emit(player_hp, player_max_hp)

func heal_player(amount: int) -> int:
	var old_hp = player_hp
	player_hp = mini(player_max_hp, player_hp + amount)
	player_hp_changed.emit(player_hp, player_max_hp)
	return player_hp - old_hp

func is_player_dead() -> bool:
	return player_hp <= 0

## Food Tokens

func add_food_tokens(amount: int) -> void:
	food_tokens += amount
	food_tokens_changed.emit(food_tokens)

func spend_food_tokens(amount: int) -> bool:
	if food_tokens >= amount:
		food_tokens -= amount
		food_tokens_changed.emit(food_tokens)
		return true
	return false

func can_afford(cost: int) -> bool:
	return food_tokens >= cost

## Energy

func restore_energy() -> void:
	energy = max_energy
	energy_changed.emit(energy, max_energy)

func spend_energy(amount: int) -> bool:
	if energy >= amount:
		energy -= amount
		energy_changed.emit(energy, max_energy)
		return true
	return false

func gain_energy(amount: int) -> void:
	energy += amount
	energy_changed.emit(energy, max_energy)

## Deck management

func add_card_to_deck(card_data):
	var card = CardInstanceClass.new(card_data)
	deck.append(card)
	deck_changed.emit()
	return card

func remove_card_from_deck(card) -> void:
	deck.erase(card)
	deck_changed.emit()

func get_deck_size() -> int:
	return deck.size()

## Combat setup

func setup_combat(enemies: Array) -> void:
	current_enemies = enemies

	# Reset combat piles
	draw_pile = deck.duplicate()
	hand.clear()
	discard_pile.clear()
	exhaust_pile.clear()

	# Reset creature combat state
	for creature in creatures:
		creature.reset_for_new_combat()

	# Restore energy
	restore_energy()

func shuffle_draw_pile() -> void:
	draw_pile.shuffle()

func draw_cards(count: int) -> Array:
	var drawn: Array = []

	for i in range(count):
		if draw_pile.is_empty():
			# Shuffle discard into draw pile
			if discard_pile.is_empty():
				break
			draw_pile = discard_pile.duplicate()
			discard_pile.clear()
			shuffle_draw_pile()

		if not draw_pile.is_empty():
			var card = draw_pile.pop_back()
			hand.append(card)
			drawn.append(card)

	return drawn

func discard_card(card) -> void:
	hand.erase(card)
	discard_pile.append(card)

func exhaust_card(card) -> void:
	hand.erase(card)
	exhaust_pile.append(card)

func discard_hand() -> void:
	for card in hand:
		# Keep creature cards in hand (they persist)
		if card.is_creature_card():
			continue
		# Check for retain keyword
		if card.has_keyword(Enums.CardKeyword.RETAIN):
			continue
		discard_pile.append(card)

	# Remove non-retained action cards from hand
	var retained: Array = []
	for card in hand:
		if card.is_creature_card() or card.has_keyword(Enums.CardKeyword.RETAIN):
			retained.append(card)
	hand = retained

## Creatures

func get_lead_creature():
	if lead_creature_index >= 0 and lead_creature_index < creatures.size():
		return creatures[lead_creature_index]
	return null

func set_lead_creature(index: int) -> void:
	if index >= 0 and index < creatures.size():
		lead_creature_index = index

func add_creature(creature_data):
	if creatures.size() >= 4:
		return null  # Max 4 creatures

	var creature = CreatureInstanceClass.new(creature_data)
	creatures.append(creature)

	# Add card to deck
	var card = CardInstanceClass.new(creature_data)
	card.creature_instance = creature
	deck.append(card)

	creature_added.emit(creature)
	deck_changed.emit()
	return creature

func get_alive_creatures() -> Array:
	var alive: Array = []
	for creature in creatures:
		if creature.is_alive():
			alive.append(creature)
	return alive

func get_creatures_on_board() -> Array:
	var on_board: Array = []
	for creature in creatures:
		if creature.board_position >= 0 and creature.is_alive():
			on_board.append(creature)
	return on_board

## Traits

func add_trait(trait_data) -> void:
	traits.append(trait_data)
	trait_acquired.emit(trait_data)

func has_trait(trait_id: String) -> bool:
	for t in traits:
		if t.id == trait_id:
			return true
	return false

func get_traits_by_trigger(trigger) -> Array:
	var matching: Array = []
	for t in traits:
		if t.trigger == trigger:
			matching.append(t)
	return matching

## Map

func get_current_map():
	return current_map

func set_current_map(map) -> void:
	current_map = map
	if current_act - 1 < maps.size():
		maps[current_act - 1] = map
	else:
		maps.append(map)

func advance_act() -> void:
	current_act += 1

func is_final_act() -> bool:
	return current_act >= 3

## Stats

func record_damage(amount: int) -> void:
	total_damage_dealt += amount

func record_card_played() -> void:
	total_cards_played += 1

func record_combat_won() -> void:
	combats_won += 1
