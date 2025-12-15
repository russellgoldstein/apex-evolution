extends Control
class_name EnemySlot
## Visual representation of an enemy

signal clicked(slot: EnemySlot)

var enemy: EnemyInstance
var is_valid_target: bool = false

@onready var background: ColorRect = $Background
@onready var name_label: Label = $NameLabel
@onready var hp_bar: ProgressBar = $HPBar
@onready var hp_label: Label = $HPBar/HPLabel
@onready var intent_container: Control = $IntentContainer
@onready var intent_icon: ColorRect = $IntentContainer/IntentIcon
@onready var intent_label: Label = $IntentContainer/IntentLabel
@onready var status_container: HBoxContainer = $StatusContainer

func _ready() -> void:
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func setup(enemy_instance: EnemyInstance) -> void:
	enemy = enemy_instance
	_update_display()

func _update_display() -> void:
	if not enemy:
		visible = false
		return

	visible = true

	# Name
	name_label.text = enemy.get_display_name()
	if enemy.data.is_elite:
		name_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))
	elif enemy.data.is_boss:
		name_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))

	# HP
	hp_bar.max_value = enemy.current_max_hp
	hp_bar.value = enemy.current_hp
	hp_label.text = "%d/%d" % [enemy.current_hp, enemy.current_max_hp]

	# Background color
	background.color = enemy.data.placeholder_color.darkened(0.3)

	# Intent
	_update_intent()

	# Status effects
	_update_status_icons()

func _update_intent() -> void:
	if not enemy or not enemy.current_intent:
		intent_container.visible = false
		return

	intent_container.visible = true
	var intent = enemy.current_intent

	# Icon color based on intent type
	match intent.intent_type:
		Enums.IntentType.ATTACK:
			intent_icon.color = Color(0.9, 0.3, 0.3)
		Enums.IntentType.DEFEND:
			intent_icon.color = Color(0.3, 0.6, 0.9)
		Enums.IntentType.BUFF:
			intent_icon.color = Color(0.3, 0.9, 0.3)
		Enums.IntentType.DEBUFF:
			intent_icon.color = Color(0.7, 0.3, 0.7)
		Enums.IntentType.SUMMON:
			intent_icon.color = Color(0.9, 0.6, 0.3)
		_:
			intent_icon.color = Color(0.5, 0.5, 0.5)

	# Intent text
	intent_label.text = intent.get_description()

func _update_status_icons() -> void:
	# Clear existing icons
	for child in status_container.get_children():
		child.queue_free()

	if not enemy:
		return

	# Add icons for each status
	for status_type in enemy.status_effects:
		var amount = enemy.status_effects[status_type]
		if amount > 0:
			var icon = _create_status_icon(status_type, amount)
			status_container.add_child(icon)

func _create_status_icon(status_type: Enums.StatusType, amount: int) -> Control:
	var container = Control.new()
	container.custom_minimum_size = Vector2(24, 24)

	var bg = ColorRect.new()
	bg.size = Vector2(24, 24)
	bg.color = _get_status_color(status_type)
	container.add_child(bg)

	var label = Label.new()
	label.text = str(amount)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = Vector2(24, 24)
	label.add_theme_font_size_override("font_size", 10)
	container.add_child(label)

	return container

func _get_status_color(status_type: Enums.StatusType) -> Color:
	match status_type:
		Enums.StatusType.SHIELD:
			return Color(0.3, 0.6, 0.9)
		Enums.StatusType.ARMOR:
			return Color(0.6, 0.6, 0.6)
		Enums.StatusType.POISON:
			return Color(0.4, 0.8, 0.2)
		Enums.StatusType.STRENGTH:
			return Color(0.9, 0.3, 0.3)
		Enums.StatusType.WEAKNESS:
			return Color(0.5, 0.3, 0.5)
		Enums.StatusType.STUNNED:
			return Color(0.8, 0.8, 0.2)
		_:
			return Color.WHITE

func set_valid_target(valid: bool) -> void:
	is_valid_target = valid
	if valid:
		modulate = Color(1.2, 0.8, 0.8)
	else:
		modulate = Color.WHITE

func flash_damage() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.5, 0.5, 0.5), 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			clicked.emit(self)

func _on_mouse_entered() -> void:
	if is_valid_target:
		scale = Vector2(1.05, 1.05)

func _on_mouse_exited() -> void:
	scale = Vector2.ONE

func refresh() -> void:
	_update_display()
