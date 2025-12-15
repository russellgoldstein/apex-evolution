extends Control
## Title screen

func _ready() -> void:
	# Connect button signals
	$VBoxContainer/NewGameButton.pressed.connect(_on_new_game_pressed)
	$VBoxContainer/ContinueButton.pressed.connect(_on_continue_pressed)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

	# Hide continue button if no save exists (for now always hide)
	$VBoxContainer/ContinueButton.visible = false

func _on_new_game_pressed() -> void:
	AudioManager.play_button_click()
	GameManager.start_new_run()

func _on_continue_pressed() -> void:
	AudioManager.play_button_click()
	# TODO: Load saved run
	pass

func _on_settings_pressed() -> void:
	AudioManager.play_button_click()
	# TODO: Open settings menu
	pass

func _on_quit_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().quit()
