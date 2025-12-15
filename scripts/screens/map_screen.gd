extends Control
## Map screen - shows the branching map and allows node selection

const MapNodeScene = preload("res://scenes/map/map_node.tscn")

@onready var map_container: Control = $ScrollContainer/MapContainer
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var act_label: Label = $TopBar/ActLabel
@onready var stats_label: Label = $TopBar/StatsLabel

var current_map: MapData
var node_buttons: Dictionary = {}  ## {Vector2i(row, col): Button}

const NODE_SPACING_X = 160
const NODE_SPACING_Y = 100
const MAP_MARGIN = 80

func _ready() -> void:
	# Check if we have a map, if not generate one
	if not RunData.current_map:
		var generator = MapGenerator.new()
		RunData.set_current_map(generator.generate_map(RunData.current_act))

	current_map = RunData.current_map

	_build_map_display()
	_update_stats()

func _build_map_display() -> void:
	# Clear existing nodes
	for child in map_container.get_children():
		child.queue_free()
	node_buttons.clear()

	if not current_map:
		return

	# Calculate map dimensions
	var max_nodes_in_row = 0
	for row in current_map.nodes:
		max_nodes_in_row = maxi(max_nodes_in_row, row.size())

	var map_width = max_nodes_in_row * NODE_SPACING_X + MAP_MARGIN * 2
	var map_height = current_map.nodes.size() * NODE_SPACING_Y + MAP_MARGIN * 2

	map_container.custom_minimum_size = Vector2(map_width, map_height)

	# Create connection lines first (so they're behind nodes)
	_draw_connections()

	# Create node buttons (bottom to top, so row 0 is at bottom)
	for row_idx in range(current_map.nodes.size()):
		var row = current_map.nodes[row_idx]
		var row_width = row.size() * NODE_SPACING_X
		var row_start_x = (map_width - row_width) / 2 + NODE_SPACING_X / 2

		# Y position: row 0 at bottom, last row at top
		var y_pos = map_height - MAP_MARGIN - (row_idx + 1) * NODE_SPACING_Y

		for col_idx in range(row.size()):
			var map_node = row[col_idx] as MapNodeData
			var x_pos = row_start_x + col_idx * NODE_SPACING_X

			var button = _create_node_button(map_node)
			button.position = Vector2(x_pos - 30, y_pos - 30)  # Center the 60x60 button
			map_container.add_child(button)

			node_buttons[Vector2i(row_idx, col_idx)] = button

	# Update accessibility
	_update_node_states()

	# Update act label
	act_label.text = "Act %d: %s" % [current_map.act_number, current_map.act_name]

	# Scroll to show current position
	_scroll_to_current()

func _create_node_button(map_node: MapNodeData) -> Button:
	var button = Button.new()
	button.custom_minimum_size = Vector2(60, 60)
	button.size = Vector2(60, 60)

	# Style based on node type
	var style = StyleBoxFlat.new()
	style.bg_color = map_node.get_color()
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8

	if map_node.node_type == Enums.NodeType.BOSS:
		style.corner_radius_bottom_left = 30
		style.corner_radius_bottom_right = 30
		style.corner_radius_top_left = 30
		style.corner_radius_top_right = 30

	button.add_theme_stylebox_override("normal", style)

	# Hover style
	var hover_style = style.duplicate() as StyleBoxFlat
	hover_style.bg_color = style.bg_color.lightened(0.2)
	button.add_theme_stylebox_override("hover", hover_style)

	# Disabled style
	var disabled_style = style.duplicate() as StyleBoxFlat
	disabled_style.bg_color = style.bg_color.darkened(0.5)
	button.add_theme_stylebox_override("disabled", disabled_style)

	# Icon/text
	button.text = _get_node_icon(map_node.node_type)

	# Connect signal
	button.pressed.connect(_on_node_pressed.bind(map_node))

	return button

func _get_node_icon(node_type: Enums.NodeType) -> String:
	match node_type:
		Enums.NodeType.COMBAT:
			return "!"
		Enums.NodeType.ELITE:
			return "!!"
		Enums.NodeType.EVOLUTION_SPIRE:
			return "$"
		Enums.NodeType.TRAIT_SHRINE:
			return "*"
		Enums.NodeType.REST_SITE:
			return "R"
		Enums.NodeType.MYSTERY:
			return "?"
		Enums.NodeType.BOSS:
			return "B"
		_:
			return "?"

func _draw_connections() -> void:
	# Create a control for drawing lines
	var lines_container = Control.new()
	lines_container.name = "Lines"
	lines_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	map_container.add_child(lines_container)

	# We'll use Line2D nodes for connections
	for row_idx in range(current_map.nodes.size() - 1):
		var row = current_map.nodes[row_idx]
		var next_row = current_map.nodes[row_idx + 1]

		var map_width = map_container.custom_minimum_size.x
		var map_height = map_container.custom_minimum_size.y

		var row_width = row.size() * NODE_SPACING_X
		var row_start_x = (map_width - row_width) / 2 + NODE_SPACING_X / 2

		var next_row_width = next_row.size() * NODE_SPACING_X
		var next_row_start_x = (map_width - next_row_width) / 2 + NODE_SPACING_X / 2

		var y_current = map_height - MAP_MARGIN - (row_idx + 1) * NODE_SPACING_Y
		var y_next = map_height - MAP_MARGIN - (row_idx + 2) * NODE_SPACING_Y

		for col_idx in range(row.size()):
			var map_node = row[col_idx] as MapNodeData
			var x_current = row_start_x + col_idx * NODE_SPACING_X

			for target_col in map_node.connections:
				var x_next = next_row_start_x + target_col * NODE_SPACING_X

				var line = Line2D.new()
				line.add_point(Vector2(x_current, y_current))
				line.add_point(Vector2(x_next, y_next))
				line.width = 3
				line.default_color = Color(0.4, 0.4, 0.4)
				lines_container.add_child(line)

func _update_node_states() -> void:
	var accessible_nodes = current_map.get_accessible_nodes()

	for key in node_buttons:
		var pos = key as Vector2i
		var button = node_buttons[key] as Button
		var map_node = current_map.get_node(pos.x, pos.y)

		if map_node.visited:
			button.disabled = true
			button.modulate = Color(0.5, 0.5, 0.5, 0.7)
		elif map_node in accessible_nodes:
			button.disabled = false
			button.modulate = Color.WHITE
		else:
			button.disabled = true
			button.modulate = Color(0.7, 0.7, 0.7, 0.5)

func _scroll_to_current() -> void:
	# Scroll to show the current row
	await get_tree().process_frame

	var target_row = current_map.current_row + 1 if current_map.current_row >= 0 else 0
	var map_height = map_container.custom_minimum_size.y
	var y_pos = map_height - MAP_MARGIN - (target_row + 1) * NODE_SPACING_Y

	var scroll_y = maxi(0, int(y_pos - scroll_container.size.y / 2))
	scroll_container.scroll_vertical = scroll_y

func _update_stats() -> void:
	stats_label.text = "HP: %d/%d | FT: %d" % [RunData.player_hp, RunData.player_max_hp, RunData.food_tokens]

func _on_node_pressed(map_node: MapNodeData) -> void:
	AudioManager.play_button_click()

	# Mark as visited
	current_map.mark_node_visited(map_node.row, map_node.column)

	# Handle node type
	match map_node.node_type:
		Enums.NodeType.COMBAT, Enums.NodeType.ELITE, Enums.NodeType.BOSS:
			RunData.current_enemies = map_node.enemies
			GameManager.enter_combat(map_node.enemies)

		Enums.NodeType.EVOLUTION_SPIRE:
			GameManager.enter_evolution_spire()

		Enums.NodeType.TRAIT_SHRINE:
			GameManager.enter_trait_shrine()

		Enums.NodeType.REST_SITE:
			GameManager.enter_rest_site()

		Enums.NodeType.MYSTERY:
			# For now, treat mystery as combat or reward
			if randf() < 0.5:
				# Free food tokens
				RunData.add_food_tokens(randi_range(20, 40))
				_update_stats()
				_update_node_states()
			else:
				# Combat
				var enemies = _get_mystery_enemies()
				RunData.current_enemies = enemies
				GameManager.enter_combat(enemies)

func _get_mystery_enemies() -> Array[EnemyData]:
	var enemies: Array[EnemyData] = []

	var mystery_enemy = EnemyData.new()
	mystery_enemy.id = "mystery_creature"
	mystery_enemy.enemy_name = "Strange Creature"
	mystery_enemy.max_hp = 20
	mystery_enemy.placeholder_color = Color(0.5, 0.5, 0.6)
	mystery_enemy.food_token_reward_min = 25
	mystery_enemy.food_token_reward_max = 35

	var attack = IntentData.new()
	attack.intent_type = Enums.IntentType.ATTACK
	attack.value = 8
	mystery_enemy.intent_pattern = [attack]

	enemies.append(mystery_enemy)
	return enemies
