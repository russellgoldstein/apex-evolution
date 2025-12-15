extends Control
## Post-combat reward screen

@onready var title_label: Label = $VBoxContainer/Title
@onready var food_label: Label = $VBoxContainer/FoodLabel
@onready var card_container: HBoxContainer = $VBoxContainer/CardContainer
@onready var skip_button: Button = $VBoxContainer/SkipButton
@onready var trait_section: VBoxContainer = $VBoxContainer/TraitSection
@onready var trait_container: HBoxContainer = $VBoxContainer/TraitSection/TraitContainer

var card_choices: Array[ActionCardData] = []
var trait_choices: Array[TraitData] = []
var has_trait_reward: bool = false

func _ready() -> void:
	skip_button.pressed.connect(_on_skip_pressed)

	# Generate card choices
	_generate_card_choices()

	# Check if we should show trait choices (elite/boss)
	has_trait_reward = _check_trait_reward()
	if has_trait_reward:
		_generate_trait_choices()
	else:
		trait_section.visible = false

	_display_rewards()

func _generate_card_choices() -> void:
	card_choices.clear()

	# Generate 3 random action cards
	var possible_cards = _get_available_cards()
	possible_cards.shuffle()

	for i in range(mini(3, possible_cards.size())):
		card_choices.append(possible_cards[i])

func _get_available_cards() -> Array[ActionCardData]:
	var cards: Array[ActionCardData] = []

	# Quick Bite
	var quick_bite = ActionCardData.new()
	quick_bite.id = "quick_bite"
	quick_bite.card_name = "Quick Bite"
	quick_bite.description = "Target creature deals 2 damage."
	quick_bite.energy_cost = 1
	quick_bite.target_type = Enums.TargetType.FRIENDLY_CREATURE
	quick_bite.requires_creature = true
	quick_bite.placeholder_color = Color(0.7, 0.3, 0.3)
	var bite_effect = EffectData.new()
	bite_effect.type = Enums.EffectType.DAMAGE
	bite_effect.value = 2
	quick_bite.effects = [bite_effect]
	cards.append(quick_bite)

	# Heavy Strike
	var heavy_strike = ActionCardData.new()
	heavy_strike.id = "heavy_strike"
	heavy_strike.card_name = "Heavy Strike"
	heavy_strike.description = "Target creature deals 8 damage."
	heavy_strike.energy_cost = 2
	heavy_strike.target_type = Enums.TargetType.FRIENDLY_CREATURE
	heavy_strike.requires_creature = true
	heavy_strike.placeholder_color = Color(0.8, 0.2, 0.2)
	var heavy_effect = EffectData.new()
	heavy_effect.type = Enums.EffectType.DAMAGE
	heavy_effect.value = 8
	heavy_strike.effects = [heavy_effect]
	cards.append(heavy_strike)

	# Iron Shell
	var iron_shell = ActionCardData.new()
	iron_shell.id = "iron_shell"
	iron_shell.card_name = "Iron Shell"
	iron_shell.description = "Target creature gains 8 Shield."
	iron_shell.energy_cost = 2
	iron_shell.target_type = Enums.TargetType.FRIENDLY_CREATURE
	iron_shell.requires_creature = true
	iron_shell.placeholder_color = Color(0.3, 0.5, 0.8)
	var shell_effect = EffectData.new()
	shell_effect.type = Enums.EffectType.SHIELD
	shell_effect.value = 8
	iron_shell.effects = [shell_effect]
	cards.append(iron_shell)

	# Poison Spit
	var poison_spit = ActionCardData.new()
	poison_spit.id = "poison_spit"
	poison_spit.card_name = "Poison Spit"
	poison_spit.description = "Apply 4 Poison to an enemy."
	poison_spit.energy_cost = 1
	poison_spit.target_type = Enums.TargetType.ENEMY
	poison_spit.requires_creature = false
	poison_spit.placeholder_color = Color(0.4, 0.7, 0.3)
	var poison_effect = EffectData.new()
	poison_effect.type = Enums.EffectType.POISON
	poison_effect.value = 4
	poison_spit.effects = [poison_effect]
	cards.append(poison_spit)

	# Second Wind
	var second_wind = ActionCardData.new()
	second_wind.id = "second_wind"
	second_wind.card_name = "Second Wind"
	second_wind.description = "Draw 3 cards."
	second_wind.energy_cost = 1
	second_wind.target_type = Enums.TargetType.NONE
	second_wind.requires_creature = false
	second_wind.placeholder_color = Color(0.6, 0.6, 0.3)
	var draw_effect = EffectData.new()
	draw_effect.type = Enums.EffectType.DRAW
	draw_effect.value = 3
	second_wind.effects = [draw_effect]
	cards.append(second_wind)

	# Regenerate
	var regenerate = ActionCardData.new()
	regenerate.id = "regenerate"
	regenerate.card_name = "Regenerate"
	regenerate.description = "Target creature heals 5 HP."
	regenerate.energy_cost = 1
	regenerate.target_type = Enums.TargetType.FRIENDLY_CREATURE
	regenerate.requires_creature = true
	regenerate.placeholder_color = Color(0.3, 0.7, 0.5)
	var heal_effect = EffectData.new()
	heal_effect.type = Enums.EffectType.HEAL
	heal_effect.value = 5
	regenerate.effects = [heal_effect]
	cards.append(regenerate)

	# Battle Cry
	var battle_cry = ActionCardData.new()
	battle_cry.id = "battle_cry"
	battle_cry.card_name = "Battle Cry"
	battle_cry.description = "Target creature gains 2 Strength."
	battle_cry.energy_cost = 1
	battle_cry.target_type = Enums.TargetType.FRIENDLY_CREATURE
	battle_cry.requires_creature = true
	battle_cry.placeholder_color = Color(0.8, 0.5, 0.3)
	var strength_effect = EffectData.new()
	strength_effect.type = Enums.EffectType.STRENGTH
	strength_effect.value = 2
	battle_cry.effects = [strength_effect]
	cards.append(battle_cry)

	# Armored Scales
	var armored_scales = ActionCardData.new()
	armored_scales.id = "armored_scales"
	armored_scales.card_name = "Armored Scales"
	armored_scales.description = "Target creature gains 3 Armor."
	armored_scales.energy_cost = 1
	armored_scales.target_type = Enums.TargetType.FRIENDLY_CREATURE
	armored_scales.requires_creature = true
	armored_scales.placeholder_color = Color(0.5, 0.5, 0.6)
	var armor_effect = EffectData.new()
	armor_effect.type = Enums.EffectType.ARMOR
	armor_effect.value = 3
	armored_scales.effects = [armor_effect]
	cards.append(armored_scales)

	return cards

func _check_trait_reward() -> bool:
	# Check if the last fight was elite or boss
	# For simplicity, check if we got a lot of food tokens
	return RunData.food_tokens > 30

func _generate_trait_choices() -> void:
	trait_choices.clear()
	var possible_traits = _get_available_traits()
	possible_traits.shuffle()

	for i in range(mini(3, possible_traits.size())):
		trait_choices.append(possible_traits[i])

func _get_available_traits() -> Array[TraitData]:
	var traits: Array[TraitData] = []

	# Swarm Tactics
	var swarm = TraitData.new()
	swarm.id = "swarm_tactics"
	swarm.trait_name = "Swarm Tactics"
	swarm.description = "When you have 2+ creatures in play, they all gain +1 ATK."
	swarm.category = TraitData.TraitCategory.COMBAT
	swarm.trigger = TraitData.TraitTrigger.PASSIVE
	traits.append(swarm)

	# Thick Hide
	var hide = TraitData.new()
	hide.id = "thick_hide"
	hide.trait_name = "Thick Hide"
	hide.description = "Your creatures take 1 less damage from all sources."
	hide.category = TraitData.TraitCategory.COMBAT
	hide.trigger = TraitData.TraitTrigger.PASSIVE
	traits.append(hide)

	# Quick Metabolism
	var metabolism = TraitData.new()
	metabolism.id = "quick_metabolism"
	metabolism.trait_name = "Quick Metabolism"
	metabolism.description = "Draw 1 extra card at the start of each turn."
	metabolism.category = TraitData.TraitCategory.DECK
	metabolism.trigger = TraitData.TraitTrigger.ON_TURN_START
	traits.append(metabolism)

	# Hunter's Instinct
	var instinct = TraitData.new()
	instinct.id = "hunters_instinct"
	instinct.trait_name = "Hunter's Instinct"
	instinct.description = "The first Attack card you play each turn costs 1 less Energy."
	instinct.category = TraitData.TraitCategory.DECK
	instinct.trigger = TraitData.TraitTrigger.PASSIVE
	traits.append(instinct)

	# Venomous
	var venomous = TraitData.new()
	venomous.id = "venomous"
	venomous.trait_name = "Venomous"
	venomous.description = "When your creatures deal damage, apply 1 Poison."
	venomous.category = TraitData.TraitCategory.COMBAT
	venomous.trigger = TraitData.TraitTrigger.ON_DAMAGE_DEALT
	traits.append(venomous)

	# Survivor
	var survivor = TraitData.new()
	survivor.id = "survivor"
	survivor.trait_name = "Survivor"
	survivor.description = "Creatures below 50% HP gain +2 ATK."
	survivor.category = TraitData.TraitCategory.COMBAT
	survivor.trigger = TraitData.TraitTrigger.PASSIVE
	traits.append(survivor)

	return traits

func _display_rewards() -> void:
	title_label.text = "Victory!"
	food_label.text = "Food Tokens Earned: +%d (Total: %d)" % [0, RunData.food_tokens]

	# Clear containers
	for child in card_container.get_children():
		child.queue_free()

	# Display card choices
	for card in card_choices:
		var card_button = _create_card_button(card)
		card_container.add_child(card_button)

	# Display trait choices if applicable
	if has_trait_reward:
		trait_section.visible = true
		for child in trait_container.get_children():
			child.queue_free()

		for trait_data in trait_choices:
			var trait_button = _create_trait_button(trait_data)
			trait_container.add_child(trait_button)
	else:
		trait_section.visible = false

func _create_card_button(card: ActionCardData) -> Button:
	var button = Button.new()
	button.custom_minimum_size = Vector2(140, 200)

	var style = StyleBoxFlat.new()
	style.bg_color = card.placeholder_color.darkened(0.3)
	style.border_width_bottom = 3
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_color = card.placeholder_color
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	button.add_theme_stylebox_override("normal", style)

	button.text = "%s\n(%d Energy)\n\n%s" % [card.card_name, card.energy_cost, card.description]

	button.pressed.connect(_on_card_selected.bind(card))

	return button

func _create_trait_button(trait_data: TraitData) -> Button:
	var button = Button.new()
	button.custom_minimum_size = Vector2(180, 120)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.3, 0.3, 0.5)
	style.border_width_bottom = 3
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_color = Color(0.6, 0.4, 0.8)
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	button.add_theme_stylebox_override("normal", style)

	button.text = "%s\n\n%s" % [trait_data.trait_name, trait_data.description]

	button.pressed.connect(_on_trait_selected.bind(trait_data))

	return button

func _on_card_selected(card: ActionCardData) -> void:
	AudioManager.play_button_click()
	RunData.add_card_to_deck(card)

	# If no trait reward, return to map
	if not has_trait_reward:
		_check_map_progress()
	else:
		# Disable card buttons, wait for trait selection
		for child in card_container.get_children():
			child.queue_free()

		var done_label = Label.new()
		done_label.text = "Card Added: " + card.card_name
		done_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		card_container.add_child(done_label)

func _on_trait_selected(trait_data: TraitData) -> void:
	AudioManager.play_trait_acquired()
	RunData.add_trait(trait_data)
	_check_map_progress()

func _on_skip_pressed() -> void:
	AudioManager.play_button_click()
	if has_trait_reward and trait_section.visible:
		# Skip trait selection
		_check_map_progress()
	else:
		# Skip card selection
		if has_trait_reward:
			# Still need to select trait
			for child in card_container.get_children():
				child.queue_free()
			var skip_label = Label.new()
			skip_label.text = "Card Skipped"
			skip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			card_container.add_child(skip_label)
		else:
			_check_map_progress()

func _check_map_progress() -> void:
	# Check if we just beat a boss
	if RunData.current_map and RunData.current_map.is_complete():
		if RunData.current_act >= 3:
			# Final boss beaten - victory!
			GameManager.victory()
		else:
			# Advance to next act
			RunData.advance_act()
			var generator = MapGenerator.new()
			RunData.set_current_map(generator.generate_map(RunData.current_act))
			GameManager.return_to_map()
	else:
		GameManager.return_to_map()
