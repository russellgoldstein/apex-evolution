extends Control
## Rest Site screen

@onready var rest_button: Button = $VBoxContainer/OptionContainer/RestButton
@onready var train_button: Button = $VBoxContainer/OptionContainer/TrainButton
@onready var reorganize_button: Button = $VBoxContainer/OptionContainer/ReorganizeButton
@onready var status_label: Label = $VBoxContainer/StatusLabel

func _ready() -> void:
	rest_button.pressed.connect(_on_rest_pressed)
	train_button.pressed.connect(_on_train_pressed)
	reorganize_button.pressed.connect(_on_reorganize_pressed)

	_update_status()

func _update_status() -> void:
	var lines: Array[String] = []
	lines.append("Player HP: %d/%d" % [RunData.player_hp, RunData.player_max_hp])

	for creature in RunData.creatures:
		lines.append("%s HP: %d/%d" % [creature.get_display_name(), creature.current_hp, creature.current_max_hp])

	status_label.text = "\n".join(lines)

	# Disable rest if at full HP
	var all_full = RunData.player_hp >= RunData.player_max_hp
	for creature in RunData.creatures:
		if creature.current_hp < creature.current_max_hp:
			all_full = false
			break

	rest_button.disabled = all_full

	# Disable reorganize if only one creature
	reorganize_button.disabled = RunData.creatures.size() <= 1

func _on_rest_pressed() -> void:
	AudioManager.play_heal()

	# Heal player for 30%
	var player_heal = int(RunData.player_max_hp * 0.3)
	RunData.heal_player(player_heal)

	# Heal all creatures for 50%
	for creature in RunData.creatures:
		var heal = int(creature.current_max_hp * 0.5)
		creature.heal(heal)

	_update_status()

	# Return to map after short delay
	await get_tree().create_timer(0.5).timeout
	GameManager.return_to_map()

func _on_train_pressed() -> void:
	AudioManager.play_button_click()

	# TODO: Show card selection UI for upgrading
	# For now, upgrade a random upgradeable card
	var upgradeable: Array[CardInstance] = []
	for card in RunData.deck:
		if card.is_action_card() and not card.is_upgraded:
			var action = card.get_action_data()
			if action and action.upgraded_version:
				upgradeable.append(card)

	if upgradeable.size() > 0:
		var to_upgrade = upgradeable[randi() % upgradeable.size()]
		to_upgrade.upgrade()

	GameManager.return_to_map()

func _on_reorganize_pressed() -> void:
	AudioManager.play_button_click()

	# Cycle lead creature
	var new_index = (RunData.lead_creature_index + 1) % RunData.creatures.size()
	RunData.set_lead_creature(new_index)

	var lead = RunData.get_lead_creature()
	if lead:
		status_label.text = "New Lead Creature: " + lead.get_display_name()

	await get_tree().create_timer(0.5).timeout
	GameManager.return_to_map()
