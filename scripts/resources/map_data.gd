class_name MapData
extends Resource
## Data for an entire act's map

@export var act_number: int = 1
@export var act_name: String = "The Shallows"

## All nodes in the map, organized by row
## nodes[row][column] = MapNodeData
@export var nodes: Array = []  # Array of Array[MapNodeData]

## Currently selected node position
@export var current_row: int = -1  # -1 means not started
@export var current_column: int = -1

func get_node(row: int, column: int) -> MapNodeData:
	if row >= 0 and row < nodes.size():
		var row_nodes = nodes[row]
		if column >= 0 and column < row_nodes.size():
			return row_nodes[column]
	return null

func get_current_node() -> MapNodeData:
	return get_node(current_row, current_column)

func get_accessible_nodes() -> Array[MapNodeData]:
	var accessible: Array[MapNodeData] = []

	# If not started, first row is accessible
	if current_row == -1:
		if nodes.size() > 0:
			for node in nodes[0]:
				accessible.append(node)
		return accessible

	# Otherwise, get connected nodes from current position
	var current = get_current_node()
	if current:
		var next_row = current_row + 1
		if next_row < nodes.size():
			for col_idx in current.connections:
				var node = get_node(next_row, col_idx)
				if node:
					accessible.append(node)

	return accessible

func mark_node_visited(row: int, column: int) -> void:
	var node = get_node(row, column)
	if node:
		node.visited = true
		current_row = row
		current_column = column

func is_complete() -> bool:
	# Map is complete when we've visited the last row (boss)
	return current_row >= nodes.size() - 1
