extends Control
## Evolution Spire - Shop screen

@onready var food_label: Label = $TopBar/FoodLabel
@onready var creature_section: VBoxContainer = $ScrollContainer/VBoxContainer/CreatureSection
@onready var creature_container: HBoxContainer = $ScrollContainer/VBoxContainer/CreatureSection/CreatureContainer
@onready var card_section: VBoxContainer = $ScrollContainer/VBoxContainer/CardSection
@onready var card_container: HBoxContainer = $ScrollContainer/VBoxContainer/CardSection/CardContainer
@onready var service_section: VBoxContainer = $ScrollContainer/VBoxContainer/ServiceSection
@onready var service_container: HBoxContainer = $ScrollContainer/VBoxContainer/ServiceSection/ServiceContainer
@onready var leave_button: Button = $LeaveButton

var cards_for_sale: Array[ActionCardData] = []
var removal_cost: int = 50

func _ready() -> void:
	leave_button.pressed.connect(_on_leave_pressed)
	_generate_shop_inventory()
	_update_display()

func _generate_shop_inventory() -> void:
	# Generate cards for sale
	cards_for_sale.clear()
	var possible_cards = _get_available_cards()
	possible_cards.shuffle()

	for i in range(mini(4, possible_cards.size())):
		cards_for_sale.append(possible_cards[i])

func _get_available_cards() -> Array[ActionCardData]:
	# Same pool as rewards but with prices
	var cards: Array[ActionCardData] = []

	var quick_bite = ActionCardData.new()
	quick_bite.id = "quick_bite"
	quick_bite.card_name = "Quick Bite"
	quick_bite.description = "Target creature deals 2 damage."
	quick_bite.energy_cost = 1
	quick_bite.rarity = Enums.Rarity.COMMON
	quick_bite.placeholder_color = Color(0.7, 0.3, 0.3)
	cards.append(quick_bite)

	var heavy_strike = ActionCardData.new()
	heavy_strike.id = "heavy_strike"
	heavy_strike.card_name = "Heavy Strike"
	heavy_strike.description = "Target creature deals 8 damage."
	heavy_strike.energy_cost = 2
	heavy_strike.rarity = Enums.Rarity.UNCOMMON
	heavy_strike.placeholder_color = Color(0.8, 0.2, 0.2)
	cards.append(heavy_strike)

	var iron_shell = ActionCardData.new()
	iron_shell.id = "iron_shell"
	iron_shell.card_name = "Iron Shell"
	iron_shell.description = "Target creature gains 8 Shield."
	iron_shell.energy_cost = 2
	iron_shell.rarity = Enums.Rarity.UNCOMMON
	iron_shell.placeholder_color = Color(0.3, 0.5, 0.8)
	cards.append(iron_shell)

	var poison_spit = ActionCardData.new()
	poison_spit.id = "poison_spit"
	poison_spit.card_name = "Poison Spit"
	poison_spit.description = "Apply 4 Poison."
	poison_spit.energy_cost = 1
	poison_spit.rarity = Enums.Rarity.COMMON
	poison_spit.placeholder_color = Color(0.4, 0.7, 0.3)
	cards.append(poison_spit)

	var battle_cry = ActionCardData.new()
	battle_cry.id = "battle_cry"
	battle_cry.card_name = "Battle Cry"
	battle_cry.description = "Target creature gains 2 Strength."
	battle_cry.energy_cost = 1
	battle_cry.rarity = Enums.Rarity.UNCOMMON
	battle_cry.placeholder_color = Color(0.8, 0.5, 0.3)
	cards.append(battle_cry)

	var frenzy = ActionCardData.new()
	frenzy.id = "frenzy"
	frenzy.card_name = "Frenzy"
	frenzy.description = "Target creature attacks all enemies."
	frenzy.energy_cost = 2
	frenzy.rarity = Enums.Rarity.RARE
	frenzy.placeholder_color = Color(0.9, 0.3, 0.5)
	cards.append(frenzy)

	return cards

func _get_card_price(card: ActionCardData) -> int:
	match card.rarity:
		Enums.Rarity.COMMON:
			return 40
		Enums.Rarity.UNCOMMON:
			return 70
		Enums.Rarity.RARE:
			return 120
		_:
			return 50

func _update_display() -> void:
	food_label.text = "Food Tokens: %d" % RunData.food_tokens

	_update_creatures()
	_update_cards()
	_update_services()

func _update_creatures() -> void:
	for child in creature_container.get_children():
		child.queue_free()

	# Show evolvable creatures
	for creature in RunData.creatures:
		if creature.evolved_data.evolution_options.size() > 0 or creature.evolution_tier < 3:
			var button = _create_evolution_button(creature)
			creature_container.add_child(button)

	if creature_container.get_child_count() == 0:
		var label = Label.new()
		label.text = "No creatures ready to evolve"
		creature_container.add_child(label)

func _create_evolution_button(creature: CreatureInstance) -> Button:
	var cost = _get_evolution_cost(creature.evolution_tier)

	var button = Button.new()
	button.custom_minimum_size = Vector2(160, 120)

	var can_afford = RunData.can_afford(cost)

	var style = StyleBoxFlat.new()
	style.bg_color = creature.evolved_data.placeholder_color.darkened(0.4)
	style.border_width_bottom = 3
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_color = Color(0.3, 0.8, 0.4) if can_afford else Color(0.5, 0.5, 0.5)
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	button.add_theme_stylebox_override("normal", style)

	button.text = "Evolve\n%s\n\n%d FT" % [creature.get_display_name(), cost]
	button.disabled = not can_afford

	button.pressed.connect(_on_evolve_pressed.bind(creature))

	return button

func _get_evolution_cost(tier: int) -> int:
	match tier:
		0: return 50
		1: return 100
		2: return 175
		_: return 250

func _update_cards() -> void:
	for child in card_container.get_children():
		child.queue_free()

	for card in cards_for_sale:
		var button = _create_card_button(card)
		card_container.add_child(button)

func _create_card_button(card: ActionCardData) -> Button:
	var price = _get_card_price(card)

	var button = Button.new()
	button.custom_minimum_size = Vector2(140, 180)

	var can_afford = RunData.can_afford(price)

	var style = StyleBoxFlat.new()
	style.bg_color = card.placeholder_color.darkened(0.4)
	style.border_width_bottom = 3
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_color = Color(1, 0.8, 0.3) if can_afford else Color(0.5, 0.5, 0.5)
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	button.add_theme_stylebox_override("normal", style)

	button.text = "%s\n(%d)\n\n%s\n\n%d FT" % [card.card_name, card.energy_cost, card.description, price]
	button.disabled = not can_afford

	button.pressed.connect(_on_card_buy_pressed.bind(card))

	return button

func _update_services() -> void:
	for child in service_container.get_children():
		child.queue_free()

	# Card removal
	var remove_button = Button.new()
	remove_button.custom_minimum_size = Vector2(140, 80)
	remove_button.text = "Remove Card\n%d FT" % removal_cost
	remove_button.disabled = not RunData.can_afford(removal_cost) or RunData.deck.size() <= 5
	remove_button.pressed.connect(_on_remove_card_pressed)
	service_container.add_child(remove_button)

	# Heal creature
	var heal_creature_cost = 25
	var heal_button = Button.new()
	heal_button.custom_minimum_size = Vector2(140, 80)
	heal_button.text = "Heal Creature\n(Full) %d FT" % heal_creature_cost
	heal_button.disabled = not RunData.can_afford(heal_creature_cost)
	heal_button.pressed.connect(_on_heal_creature_pressed.bind(heal_creature_cost))
	service_container.add_child(heal_button)

	# Heal player
	var heal_player_cost = 30
	var heal_player_button = Button.new()
	heal_player_button.custom_minimum_size = Vector2(140, 80)
	heal_player_button.text = "Heal Player\n(30%%) %d FT" % heal_player_cost
	heal_player_button.disabled = not RunData.can_afford(heal_player_cost) or RunData.player_hp >= RunData.player_max_hp
	heal_player_button.pressed.connect(_on_heal_player_pressed.bind(heal_player_cost))
	service_container.add_child(heal_player_button)

func _on_evolve_pressed(creature: CreatureInstance) -> void:
	var cost = _get_evolution_cost(creature.evolution_tier)

	if RunData.spend_food_tokens(cost):
		AudioManager.play_evolution()
		# Simple evolution: increase stats
		var evolved = CreatureCardData.new()
		evolved.id = creature.evolved_data.id + "_evolved"
		evolved.card_name = creature.evolved_data.card_name + "+"
		evolved.attack = creature.evolved_data.attack + 1
		evolved.max_hp = creature.evolved_data.max_hp + 2
		evolved.energy_cost = creature.evolved_data.energy_cost
		evolved.species_types = creature.evolved_data.species_types
		evolved.placeholder_color = creature.evolved_data.placeholder_color.lightened(0.1)

		creature.evolve(evolved)
		_update_display()

func _on_card_buy_pressed(card: ActionCardData) -> void:
	var price = _get_card_price(card)

	if RunData.spend_food_tokens(price):
		AudioManager.play_button_click()
		RunData.add_card_to_deck(card)
		cards_for_sale.erase(card)
		_update_display()

func _on_remove_card_pressed() -> void:
	# TODO: Show card selection UI
	# For now, remove a random non-creature card
	if RunData.spend_food_tokens(removal_cost):
		AudioManager.play_button_click()
		var removable: Array[CardInstance] = []
		for card in RunData.deck:
			if card.is_action_card():
				removable.append(card)

		if removable.size() > 0:
			var to_remove = removable[randi() % removable.size()]
			RunData.remove_card_from_deck(to_remove)
			removal_cost += 25  # Increase cost each time
			_update_display()

func _on_heal_creature_pressed(cost: int) -> void:
	if RunData.spend_food_tokens(cost):
		AudioManager.play_heal()
		for creature in RunData.creatures:
			creature.current_hp = creature.current_max_hp
		_update_display()

func _on_heal_player_pressed(cost: int) -> void:
	if RunData.spend_food_tokens(cost):
		AudioManager.play_heal()
		var heal_amount = int(RunData.player_max_hp * 0.3)
		RunData.heal_player(heal_amount)
		_update_display()

func _on_leave_pressed() -> void:
	AudioManager.play_button_click()
	GameManager.return_to_map()
