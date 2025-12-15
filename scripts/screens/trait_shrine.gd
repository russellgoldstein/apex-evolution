extends Control
## Trait Shrine - free trait selection

@onready var trait_container: HBoxContainer = $VBoxContainer/TraitContainer
@onready var skip_button: Button = $VBoxContainer/SkipButton

var trait_choices: Array[TraitData] = []

func _ready() -> void:
	skip_button.pressed.connect(_on_skip_pressed)
	_generate_trait_choices()
	_display_traits()

func _generate_trait_choices() -> void:
	trait_choices.clear()
	var possible_traits = _get_available_traits()
	possible_traits.shuffle()

	for i in range(mini(3, possible_traits.size())):
		trait_choices.append(possible_traits[i])

func _get_available_traits() -> Array[TraitData]:
	# Same pool as reward screen
	var traits: Array[TraitData] = []

	var swarm = TraitData.new()
	swarm.id = "swarm_tactics"
	swarm.trait_name = "Swarm Tactics"
	swarm.description = "When you have 2+ creatures in play, they all gain +1 ATK."
	swarm.category = TraitData.TraitCategory.COMBAT
	traits.append(swarm)

	var hide = TraitData.new()
	hide.id = "thick_hide"
	hide.trait_name = "Thick Hide"
	hide.description = "Your creatures take 1 less damage from all sources."
	hide.category = TraitData.TraitCategory.COMBAT
	traits.append(hide)

	var metabolism = TraitData.new()
	metabolism.id = "quick_metabolism"
	metabolism.trait_name = "Quick Metabolism"
	metabolism.description = "Draw 1 extra card at the start of each turn."
	metabolism.category = TraitData.TraitCategory.DECK
	traits.append(metabolism)

	var instinct = TraitData.new()
	instinct.id = "hunters_instinct"
	instinct.trait_name = "Hunter's Instinct"
	instinct.description = "The first Attack card you play each turn costs 1 less."
	instinct.category = TraitData.TraitCategory.DECK
	traits.append(instinct)

	var venomous = TraitData.new()
	venomous.id = "venomous"
	venomous.trait_name = "Venomous"
	venomous.description = "When your creatures deal damage, apply 1 Poison."
	venomous.category = TraitData.TraitCategory.COMBAT
	traits.append(venomous)

	var survivor = TraitData.new()
	survivor.id = "survivor"
	survivor.trait_name = "Survivor"
	survivor.description = "Creatures below 50% HP gain +2 ATK."
	survivor.category = TraitData.TraitCategory.COMBAT
	traits.append(survivor)

	var chimeric = TraitData.new()
	chimeric.id = "chimeric_vigor"
	chimeric.trait_name = "Chimeric Vigor"
	chimeric.description = "Creatures with 2+ types have +3 max HP."
	chimeric.category = TraitData.TraitCategory.HYBRID
	traits.append(chimeric)

	var adaptive = TraitData.new()
	adaptive.id = "adaptive_genetics"
	adaptive.trait_name = "Adaptive Genetics"
	adaptive.description = "Creatures with 2+ types gain Regeneration 1."
	adaptive.category = TraitData.TraitCategory.HYBRID
	traits.append(adaptive)

	# Filter out already owned traits
	var filtered: Array[TraitData] = []
	for t in traits:
		if not RunData.has_trait(t.id):
			filtered.append(t)

	return filtered

func _display_traits() -> void:
	for child in trait_container.get_children():
		child.queue_free()

	for trait_data in trait_choices:
		var button = _create_trait_button(trait_data)
		trait_container.add_child(button)

func _create_trait_button(trait_data: TraitData) -> Button:
	var button = Button.new()
	button.custom_minimum_size = Vector2(200, 150)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.25, 0.25, 0.4)
	style.border_width_bottom = 3
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_color = Color(0.6, 0.4, 0.8)
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	button.add_theme_stylebox_override("normal", style)

	var hover_style = style.duplicate() as StyleBoxFlat
	hover_style.bg_color = Color(0.35, 0.35, 0.5)
	button.add_theme_stylebox_override("hover", hover_style)

	button.text = "%s\n[%s]\n\n%s" % [trait_data.trait_name, trait_data.get_category_string(), trait_data.description]

	button.pressed.connect(_on_trait_selected.bind(trait_data))

	return button

func _on_trait_selected(trait_data: TraitData) -> void:
	AudioManager.play_trait_acquired()
	RunData.add_trait(trait_data)
	GameManager.return_to_map()

func _on_skip_pressed() -> void:
	AudioManager.play_button_click()
	GameManager.return_to_map()
