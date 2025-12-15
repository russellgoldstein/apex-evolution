extends Control
class_name CardHand
## Manages the visual hand of cards

signal card_clicked(card_ui: CardUI)
signal card_drag_started(card_ui: CardUI)
signal card_drag_ended(card_ui: CardUI)
signal card_dropped_on_target(card_ui: CardUI)

const CardScene = preload("res://scenes/combat/card.tscn")

@export var hand_width: float = 600.0
@export var card_spacing: float = -40.0  ## Negative for overlap
@export var fan_angle: float = 3.0  ## Degrees per card from center
@export var vertical_offset: float = 10.0  ## Cards at edges are lower

var card_uis: Array[CardUI] = []
var is_dragging_card: bool = false
var dragged_card: CardUI

func _ready() -> void:
	pass

func update_hand(cards: Array[CardInstance], combat_manager: CombatManager) -> void:
	## Rebuild the hand display
	# Clear existing cards
	for card_ui in card_uis:
		card_ui.queue_free()
	card_uis.clear()

	# Create new card UIs
	for card in cards:
		var card_ui = CardScene.instantiate() as CardUI
		add_child(card_ui)
		card_ui.setup(card)

		# Set playability
		var playable = combat_manager.can_play_card(card)
		card_ui.set_playable(playable)

		# Connect signals
		card_ui.clicked.connect(_on_card_clicked)
		card_ui.drag_started.connect(_on_card_drag_started)
		card_ui.drag_ended.connect(_on_card_drag_ended)

		card_uis.append(card_ui)

	# Arrange cards
	_arrange_cards()

func _arrange_cards(animated: bool = false) -> void:
	var count = card_uis.size()
	if count == 0:
		return

	var total_width = count * (120 + card_spacing) - card_spacing
	var start_x = (size.x - total_width) / 2

	for i in range(count):
		var card_ui = card_uis[i]

		# Calculate position
		var x = start_x + i * (120 + card_spacing)
		var center_offset = float(i) - float(count - 1) / 2.0

		# Fan effect
		var rotation = deg_to_rad(center_offset * fan_angle)
		var y_offset = abs(center_offset) * vertical_offset

		var target_pos = Vector2(x, y_offset)

		if animated:
			var tween = create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(card_ui, "position", target_pos, 0.2)
			tween.parallel().tween_property(card_ui, "rotation", rotation, 0.2)
		else:
			card_ui.set_hand_position(target_pos, rotation, i)

func add_card(card: CardInstance, combat_manager: CombatManager) -> void:
	var card_ui = CardScene.instantiate() as CardUI
	add_child(card_ui)
	card_ui.setup(card)

	var playable = combat_manager.can_play_card(card)
	card_ui.set_playable(playable)

	card_ui.clicked.connect(_on_card_clicked)
	card_ui.drag_started.connect(_on_card_drag_started)
	card_ui.drag_ended.connect(_on_card_drag_ended)

	# Start off-screen
	card_ui.position = Vector2(size.x / 2, -200)
	card_ui.modulate.a = 0

	card_uis.append(card_ui)

	# Animate in
	var tween = create_tween()
	tween.tween_property(card_ui, "modulate:a", 1.0, 0.2)
	await tween.finished

	_arrange_cards(true)

func remove_card(card_ui: CardUI) -> void:
	card_uis.erase(card_ui)
	await card_ui.play_animation()
	_arrange_cards(true)

func update_playability(combat_manager: CombatManager) -> void:
	for card_ui in card_uis:
		if card_ui.card_instance:
			var playable = combat_manager.can_play_card(card_ui.card_instance)
			card_ui.set_playable(playable)

func _on_card_clicked(card_ui: CardUI) -> void:
	card_clicked.emit(card_ui)

func _on_card_drag_started(card_ui: CardUI) -> void:
	is_dragging_card = true
	dragged_card = card_ui
	card_drag_started.emit(card_ui)

func _on_card_drag_ended(card_ui: CardUI) -> void:
	is_dragging_card = false

	# Check if card was dropped on a valid target
	# This will be handled by the combat screen
	card_drag_ended.emit(card_ui)

	# Return card to hand if not played
	if card_ui.is_inside_tree():
		_arrange_cards(true)

	dragged_card = null

func get_card_ui_for_instance(card: CardInstance) -> CardUI:
	for card_ui in card_uis:
		if card_ui.card_instance == card:
			return card_ui
	return null
