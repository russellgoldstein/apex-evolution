extends Control
class_name CardUI
## Visual representation of a card in hand

signal clicked(card_ui: CardUI)
signal hovered(card_ui: CardUI, is_hovering: bool)
signal drag_started(card_ui: CardUI)
signal drag_ended(card_ui: CardUI)

@export var card_width: float = 120
@export var card_height: float = 180

var card_instance: CardInstance
var is_dragging: bool = false
var is_hovering: bool = false
var original_position: Vector2
var original_index: int = 0
var is_playable: bool = true

## Visual elements
@onready var background: ColorRect = $Background
@onready var name_label: Label = $NameLabel
@onready var cost_label: Label = $CostLabel
@onready var description_label: Label = $DescriptionLabel
@onready var stats_label: Label = $StatsLabel
@onready var type_indicator: ColorRect = $TypeIndicator

## Animation
var hover_tween: Tween
var return_tween: Tween
const HOVER_LIFT: float = -30.0
const HOVER_SCALE: float = 1.15

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)

	custom_minimum_size = Vector2(card_width, card_height)
	size = Vector2(card_width, card_height)
	pivot_offset = size / 2

func setup(instance: CardInstance) -> void:
	card_instance = instance
	_update_visuals()

func _update_visuals() -> void:
	if not card_instance:
		return

	var data = card_instance.get_data()

	# Name
	name_label.text = card_instance.get_name()

	# Cost
	cost_label.text = str(card_instance.get_energy_cost())

	# Background color
	background.color = data.placeholder_color

	# Type indicator
	if card_instance.is_creature_card():
		type_indicator.color = Color(0.3, 0.7, 0.3)  # Green for creatures
		var creature = card_instance.get_creature_data()
		stats_label.text = "%d / %d" % [creature.attack, creature.max_hp]
		stats_label.visible = true
		description_label.text = creature.get_species_string()
	else:
		type_indicator.color = Color(0.3, 0.3, 0.7)  # Blue for actions
		stats_label.visible = false
		description_label.text = data.description

	# Playability visual
	_update_playability_visual()

func _update_playability_visual() -> void:
	if is_playable:
		modulate = Color.WHITE
	else:
		modulate = Color(0.6, 0.6, 0.6)

func set_playable(playable: bool) -> void:
	is_playable = playable
	_update_playability_visual()

func _on_mouse_entered() -> void:
	if is_dragging:
		return

	is_hovering = true
	hovered.emit(self, true)
	_animate_hover(true)

func _on_mouse_exited() -> void:
	if is_dragging:
		return

	is_hovering = false
	hovered.emit(self, false)
	_animate_hover(false)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if is_playable:
					_start_drag()
					clicked.emit(self)
			else:
				if is_dragging:
					_end_drag()

	elif event is InputEventMouseMotion:
		if is_dragging:
			global_position = get_global_mouse_position() - size / 2

func _start_drag() -> void:
	if not is_playable:
		return

	is_dragging = true
	original_position = position
	z_index = 100
	drag_started.emit(self)

	# Cancel hover animation
	if hover_tween:
		hover_tween.kill()
	scale = Vector2(HOVER_SCALE, HOVER_SCALE)

func _end_drag() -> void:
	is_dragging = false
	z_index = 0
	drag_ended.emit(self)

func return_to_hand(target_position: Vector2) -> void:
	if return_tween:
		return_tween.kill()

	return_tween = create_tween()
	return_tween.set_ease(Tween.EASE_OUT)
	return_tween.set_trans(Tween.TRANS_BACK)
	return_tween.tween_property(self, "position", target_position, 0.3)
	return_tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.3)
	return_tween.parallel().tween_property(self, "rotation", 0.0, 0.3)

func _animate_hover(hovering: bool) -> void:
	if hover_tween:
		hover_tween.kill()

	hover_tween = create_tween()
	hover_tween.set_ease(Tween.EASE_OUT)
	hover_tween.set_trans(Tween.TRANS_CUBIC)

	if hovering:
		hover_tween.tween_property(self, "position:y", original_position.y + HOVER_LIFT, 0.15)
		hover_tween.parallel().tween_property(self, "scale", Vector2(HOVER_SCALE, HOVER_SCALE), 0.15)
		hover_tween.parallel().tween_property(self, "rotation", 0.0, 0.15)
	else:
		hover_tween.tween_property(self, "position:y", original_position.y, 0.15)
		hover_tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.15)

func play_animation() -> void:
	## Animation when card is played
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.5, 0.5), 0.2)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.2)
	await tween.finished
	queue_free()

func set_hand_position(pos: Vector2, rot: float, idx: int) -> void:
	original_position = pos
	original_index = idx
	position = pos
	rotation = rot
