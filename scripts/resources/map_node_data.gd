class_name MapNodeData
extends Resource
## Data for a single map node

@export var node_type: Enums.NodeType = Enums.NodeType.COMBAT
@export var row: int = 0
@export var column: int = 0

## Connections to next row nodes (indices)
@export var connections: Array[int] = []

## For combat nodes
@export var enemies: Array = []  # Array of EnemyData

## Whether this node has been visited
@export var visited: bool = false

## Whether this node is currently accessible
@export var accessible: bool = false

func get_icon_name() -> String:
	match node_type:
		Enums.NodeType.COMBAT:
			return "combat"
		Enums.NodeType.ELITE:
			return "elite"
		Enums.NodeType.EVOLUTION_SPIRE:
			return "shop"
		Enums.NodeType.TRAIT_SHRINE:
			return "trait"
		Enums.NodeType.REST_SITE:
			return "rest"
		Enums.NodeType.MYSTERY:
			return "mystery"
		Enums.NodeType.BOSS:
			return "boss"
		_:
			return "unknown"

func get_display_name() -> String:
	match node_type:
		Enums.NodeType.COMBAT:
			return "Combat"
		Enums.NodeType.ELITE:
			return "Elite"
		Enums.NodeType.EVOLUTION_SPIRE:
			return "Evolution Spire"
		Enums.NodeType.TRAIT_SHRINE:
			return "Trait Shrine"
		Enums.NodeType.REST_SITE:
			return "Rest Site"
		Enums.NodeType.MYSTERY:
			return "Mystery"
		Enums.NodeType.BOSS:
			return "Boss"
		_:
			return "Unknown"

func get_color() -> Color:
	match node_type:
		Enums.NodeType.COMBAT:
			return Color(0.7, 0.7, 0.7)  # Gray
		Enums.NodeType.ELITE:
			return Color(1.0, 0.8, 0.2)  # Gold
		Enums.NodeType.EVOLUTION_SPIRE:
			return Color(0.2, 0.8, 0.4)  # Green
		Enums.NodeType.TRAIT_SHRINE:
			return Color(0.8, 0.4, 0.8)  # Purple
		Enums.NodeType.REST_SITE:
			return Color(0.4, 0.7, 1.0)  # Blue
		Enums.NodeType.MYSTERY:
			return Color(0.6, 0.6, 0.6)  # Dark gray
		Enums.NodeType.BOSS:
			return Color(1.0, 0.3, 0.3)  # Red
		_:
			return Color.WHITE
