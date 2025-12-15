extends Control
class_name CreatureSlot
## Visual representation of a creature on the battlefield

signal clicked(slot: CreatureSlot)

var creature: CreatureInstance
var is_valid_target: bool = false
var is_selected: bool = false

@onready var background: ColorRect = $Background
@onready var name_label: Label = $NameLabel
@onready var hp_bar: ProgressBar = $HPBar
@onready var hp_label: Label = $HPBar/HPLabel
@onready var attack_label: Label = $AttackLabel
@onready var status_container: HBoxContainer = $StatusContainer

func _ready() -> void:
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func setup(creature_instance: CreatureInstance) -> void:
	creature = creature_instance
	_update_display()

func _update_display() -> void:
	if not creature:
		visible = false
		return

	visible = true

	# Name
	name_label.text = creature.get_display_name()

	# HP
	hp_bar.max_value = creature.current_max_hp
	hp_bar.value = creature.current_hp
	hp_label.text = "%d/%d" % [creature.current_hp, creature.current_max_hp]

	# Attack
	var attack = creature.get_attack_damage()
	attack_label.text = str(attack)
	if creature.has_status(Enums.StatusType.STRENGTH):
		attack_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
	elif creature.has_status(Enums.StatusType.WEAKNESS):
		attack_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	else:
		attack_label.add_theme_color_override("font_color", Color.WHITE)

	# Background color based on species
	if creature.evolved_data and creature.evolved_data.species_types.size() > 0:
		background.color = creature.evolved_data.placeholder_color.darkened(0.3)
	else:
		background.color = Color(0.2, 0.4, 0.3)

	# Status effects
	_update_status_icons()

func _update_status_icons() -> void:
	# Clear existing icons
	for child in status_container.get_children():
		child.queue_free()

	if not creature:
		return

	# Add icons for each status
	for status_type in creature.status_effects:
		var amount = creature.status_effects[status_type]
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
		Enums.StatusType.REGENERATION:
			return Color(0.2, 0.9, 0.4)
		Enums.StatusType.STRENGTH:
			return Color(0.9, 0.3, 0.3)
		Enums.StatusType.WEAKNESS:
			return Color(0.5, 0.3, 0.5)
		Enums.StatusType.FLYING:
			return Color(0.7, 0.7, 0.9)
		Enums.StatusType.STUNNED:
			return Color(0.8, 0.8, 0.2)
		_:
			return Color.WHITE

func set_valid_target(valid: bool) -> void:
	is_valid_target = valid
	if valid:
		modulate = Color(1.2, 1.2, 0.8)
	else:
		modulate = Color.WHITE

func set_selected(selected: bool) -> void:
	is_selected = selected
	if selected:
		modulate = Color(0.8, 1.2, 0.8)
	else:
		modulate = Color.WHITE

func flash_damage() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.5, 0.5, 0.5), 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)

func flash_heal() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(0.5, 1.5, 0.5), 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)

func flash_shield() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(0.5, 0.8, 1.5), 0.1)
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
