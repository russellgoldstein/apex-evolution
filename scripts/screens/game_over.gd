extends Control
## Game Over screen

@onready var stats_label: Label = $VBoxContainer/StatsLabel
@onready var retry_button: Button = $VBoxContainer/RetryButton
@onready var menu_button: Button = $VBoxContainer/MenuButton

func _ready() -> void:
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

	_display_stats()

func _display_stats() -> void:
	var lines: Array[String] = []

	lines.append("Act Reached: %d" % RunData.current_act)
	lines.append("Combats Won: %d" % RunData.combats_won)
	lines.append("Total Damage: %d" % RunData.total_damage_dealt)
	lines.append("Cards Played: %d" % RunData.total_cards_played)
	lines.append("Food Tokens: %d" % RunData.food_tokens)
	lines.append("Traits Acquired: %d" % RunData.traits.size())

	if RunData.current_archetype:
		lines.append("Archetype: %s" % RunData.current_archetype.archetype_name)

	stats_label.text = "\n".join(lines)

func _on_retry_pressed() -> void:
	AudioManager.play_button_click()
	GameManager.start_new_run()

func _on_menu_pressed() -> void:
	AudioManager.play_button_click()
	GameManager.return_to_main_menu()
