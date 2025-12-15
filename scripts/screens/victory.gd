extends Control
## Victory screen

@onready var stats_label: Label = $VBoxContainer/StatsLabel
@onready var continue_button: Button = $VBoxContainer/ContinueButton
@onready var menu_button: Button = $VBoxContainer/MenuButton

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

	_display_stats()

func _display_stats() -> void:
	var lines: Array[String] = []

	lines.append("You have become the Apex!")
	lines.append("")
	lines.append("Combats Won: %d" % RunData.combats_won)
	lines.append("Total Damage: %d" % RunData.total_damage_dealt)
	lines.append("Cards Played: %d" % RunData.total_cards_played)
	lines.append("Food Tokens: %d" % RunData.food_tokens)
	lines.append("Traits Acquired: %d" % RunData.traits.size())

	# Show evolved creatures
	lines.append("")
	lines.append("Final Evolution:")
	for creature in RunData.creatures:
		var tier_str = "Tier %d" % creature.evolution_tier
		lines.append("  %s (%s)" % [creature.get_display_name(), tier_str])

	if RunData.current_archetype:
		lines.append("")
		lines.append("Archetype: %s" % RunData.current_archetype.archetype_name)

	stats_label.text = "\n".join(lines)

func _on_continue_pressed() -> void:
	AudioManager.play_button_click()
	# Start a new run with the same archetype
	GameManager.start_new_run()

func _on_menu_pressed() -> void:
	AudioManager.play_button_click()
	GameManager.return_to_main_menu()
