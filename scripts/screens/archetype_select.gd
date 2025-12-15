extends Control
## Archetype selection screen

signal archetype_selected(archetype: ArchetypeData)

@onready var archetype_container: HBoxContainer = $VBoxContainer/ArchetypeContainer
@onready var description_label: Label = $VBoxContainer/DescriptionPanel/Description
@onready var start_button: Button = $VBoxContainer/StartButton

var archetypes: Array[ArchetypeData] = []
var selected_archetype: ArchetypeData
var archetype_buttons: Array[Button] = []

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	start_button.disabled = true

	# Load archetypes
	_load_archetypes()
	_create_archetype_buttons()

func _load_archetypes() -> void:
	# Load archetype resources
	# For now, create them programmatically
	archetypes = _create_default_archetypes()

func _create_default_archetypes() -> Array[ArchetypeData]:
	var result: Array[ArchetypeData] = []

	# Insectoid archetype
	var insectoid = ArchetypeData.new()
	insectoid.id = "insectoid"
	insectoid.archetype_name = "The Insectoid"
	insectoid.description = "Begin with a basic Insectoid creature. Balanced playstyle, good for learning the game."
	insectoid.color = Color(0.4, 0.7, 0.3)
	insectoid.starting_creature = _create_starter_creature("insectoid")
	insectoid.starting_deck = _create_starter_deck()
	insectoid.starting_trait = _create_starter_trait("insectoid")
	result.append(insectoid)

	# Mammal archetype
	var mammal = ArchetypeData.new()
	mammal.id = "mammal"
	mammal.archetype_name = "The Mammal"
	mammal.description = "Begin with an aggressive Wolf Pup. Rewards quick kills with bonus strength."
	mammal.color = Color(0.8, 0.5, 0.3)
	mammal.starting_creature = _create_starter_creature("mammal")
	mammal.starting_deck = _create_starter_deck()
	mammal.starting_trait = _create_starter_trait("mammal")
	result.append(mammal)

	# Reptile archetype
	var reptile = ArchetypeData.new()
	reptile.id = "reptile"
	reptile.archetype_name = "The Reptile"
	reptile.description = "Begin with a durable Hatchling Lizard. Defensive playstyle with armor bonuses."
	reptile.color = Color(0.3, 0.6, 0.5)
	reptile.starting_creature = _create_starter_creature("reptile")
	reptile.starting_deck = _create_starter_deck()
	reptile.starting_trait = _create_starter_trait("reptile")
	result.append(reptile)

	return result

func _create_starter_creature(type: String) -> CreatureCardData:
	var creature = CreatureCardData.new()

	match type:
		"insectoid":
			creature.id = "infant_insectoid"
			creature.card_name = "Infant Insectoid"
			creature.attack = 1
			creature.max_hp = 4
			creature.energy_cost = 1
			creature.species_types = [Enums.SpeciesType.INSECTOID]
			creature.placeholder_color = Color(0.4, 0.7, 0.3)
		"mammal":
			creature.id = "wolf_pup"
			creature.card_name = "Wolf Pup"
			creature.attack = 2
			creature.max_hp = 3
			creature.energy_cost = 1
			creature.species_types = [Enums.SpeciesType.MAMMAL]
			creature.placeholder_color = Color(0.8, 0.5, 0.3)
		"reptile":
			creature.id = "hatchling_lizard"
			creature.card_name = "Hatchling Lizard"
			creature.attack = 1
			creature.max_hp = 6
			creature.energy_cost = 1
			creature.species_types = [Enums.SpeciesType.REPTILE]
			creature.placeholder_color = Color(0.3, 0.6, 0.5)

	return creature

func _create_starter_deck() -> Array[ActionCardData]:
	var deck: Array[ActionCardData] = []

	# 4x Strike
	for i in range(4):
		var strike = ActionCardData.new()
		strike.id = "strike"
		strike.card_name = "Strike"
		strike.description = "Target creature deals 3 damage."
		strike.energy_cost = 1
		strike.target_type = Enums.TargetType.FRIENDLY_CREATURE
		strike.requires_creature = true

		var damage_effect = EffectData.new()
		damage_effect.type = Enums.EffectType.DAMAGE
		damage_effect.value = 3
		strike.effects = [damage_effect]
		strike.placeholder_color = Color(0.7, 0.3, 0.3)

		deck.append(strike)

	# 3x Defend
	for i in range(3):
		var defend = ActionCardData.new()
		defend.id = "defend"
		defend.card_name = "Defend"
		defend.description = "Target creature gains 4 Shield."
		defend.energy_cost = 1
		defend.target_type = Enums.TargetType.FRIENDLY_CREATURE
		defend.requires_creature = true

		var shield_effect = EffectData.new()
		shield_effect.type = Enums.EffectType.SHIELD
		shield_effect.value = 4
		defend.effects = [shield_effect]
		defend.placeholder_color = Color(0.3, 0.5, 0.7)

		deck.append(defend)

	# 1x Adrenaline Rush (Universal)
	var adrenaline = ActionCardData.new()
	adrenaline.id = "adrenaline_rush"
	adrenaline.card_name = "Adrenaline Rush"
	adrenaline.description = "Draw 2 cards."
	adrenaline.energy_cost = 1
	adrenaline.target_type = Enums.TargetType.NONE
	adrenaline.requires_creature = false

	var draw_effect = EffectData.new()
	draw_effect.type = Enums.EffectType.DRAW
	draw_effect.value = 2
	adrenaline.effects = [draw_effect]
	adrenaline.placeholder_color = Color(0.7, 0.7, 0.3)

	deck.append(adrenaline)

	return deck

func _create_starter_trait(type: String) -> TraitData:
	var trait_res = TraitData.new()

	match type:
		"insectoid":
			trait_res.id = "compound_eyes"
			trait_res.trait_name = "Compound Eyes"
			trait_res.description = "At the start of combat, look at the top 2 cards of your deck."
			trait_res.trigger = TraitData.TraitTrigger.ON_COMBAT_START
			trait_res.category = TraitData.TraitCategory.DECK
		"mammal":
			trait_res.id = "bloodlust"
			trait_res.trait_name = "Bloodlust"
			trait_res.description = "After killing an enemy, your creatures gain +1 Strength this combat."
			trait_res.trigger = TraitData.TraitTrigger.ON_ENEMY_DEATH
			trait_res.category = TraitData.TraitCategory.COMBAT
		"reptile":
			trait_res.id = "thick_scales"
			trait_res.trait_name = "Thick Scales"
			trait_res.description = "Your Lead Creature starts each combat with 3 Armor."
			trait_res.trigger = TraitData.TraitTrigger.ON_COMBAT_START
			trait_res.category = TraitData.TraitCategory.SPECIES

	return trait_res

func _create_archetype_buttons() -> void:
	# Clear existing buttons
	for child in archetype_container.get_children():
		child.queue_free()
	archetype_buttons.clear()

	# Create button for each archetype
	for archetype in archetypes:
		var button = Button.new()
		button.custom_minimum_size = Vector2(180, 200)
		button.text = archetype.archetype_name

		# Style the button
		var style = StyleBoxFlat.new()
		style.bg_color = archetype.color.darkened(0.5)
		style.border_width_bottom = 4
		style.border_width_left = 4
		style.border_width_right = 4
		style.border_width_top = 4
		style.border_color = archetype.color
		style.corner_radius_bottom_left = 8
		style.corner_radius_bottom_right = 8
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		button.add_theme_stylebox_override("normal", style)

		var hover_style = style.duplicate()
		hover_style.bg_color = archetype.color.darkened(0.3)
		button.add_theme_stylebox_override("hover", hover_style)

		var pressed_style = style.duplicate()
		pressed_style.bg_color = archetype.color
		button.add_theme_stylebox_override("pressed", pressed_style)

		button.pressed.connect(_on_archetype_button_pressed.bind(archetype))

		archetype_container.add_child(button)
		archetype_buttons.append(button)

func _on_archetype_button_pressed(archetype: ArchetypeData) -> void:
	AudioManager.play_button_click()
	selected_archetype = archetype
	start_button.disabled = false

	# Update description
	description_label.text = archetype.description + "\n\n"
	description_label.text += "Starting Creature: " + archetype.starting_creature.card_name + "\n"
	description_label.text += "Starting Trait: " + archetype.starting_trait.trait_name

	# Highlight selected button
	for i in range(archetype_buttons.size()):
		var btn = archetype_buttons[i]
		var arch = archetypes[i]
		if arch == selected_archetype:
			btn.modulate = Color.WHITE
		else:
			btn.modulate = Color(0.7, 0.7, 0.7)

func _on_start_pressed() -> void:
	if selected_archetype:
		AudioManager.play_button_click()
		GameManager.select_archetype(selected_archetype)
