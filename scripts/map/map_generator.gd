class_name MapGenerator
extends RefCounted
## Generates procedural maps for each act

const ROWS_PER_ACT = 15
const MIN_NODES_PER_ROW = 2
const MAX_NODES_PER_ROW = 4

## Node distribution rules
const NODE_DISTRIBUTION = {
	"combat": 0.45,
	"elite": 0.12,
	"evolution_spire": 0.10,
	"trait_shrine": 0.08,
	"rest_site": 0.15,
	"mystery": 0.10
}

## Row restrictions
const ELITE_MIN_ROW = 5
const REST_GUARANTEED_ROW_MIN = 6
const REST_GUARANTEED_ROW_MAX = 8

func generate_map(act: int) -> MapData:
	var map = MapData.new()
	map.act_number = act
	map.act_name = _get_act_name(act)

	# Initialize nodes array
	map.nodes = []

	# Generate nodes for each row
	for row in range(ROWS_PER_ACT):
		var row_nodes = _generate_row(row, act)
		map.nodes.append(row_nodes)

	# Generate connections between rows
	_generate_connections(map)

	# Assign node types
	_assign_node_types(map, act)

	# Assign enemies to combat nodes
	_assign_enemies(map, act)

	return map

func _get_act_name(act: int) -> String:
	match act:
		1: return "The Shallows"
		2: return "The Depths"
		3: return "The Apex"
		_: return "Unknown"

func _generate_row(row: int, _act: int) -> Array:
	var row_nodes: Array = []

	var node_count: int
	if row == 0:
		# First row: always start with 2-3 nodes
		node_count = randi_range(2, 3)
	elif row == ROWS_PER_ACT - 1:
		# Last row: always 1 node (boss)
		node_count = 1
	else:
		# Middle rows: variable
		node_count = randi_range(MIN_NODES_PER_ROW, MAX_NODES_PER_ROW)

	for col in range(node_count):
		var node = MapNodeData.new()
		node.row = row
		node.column = col
		node.visited = false
		node.accessible = (row == 0)  # First row is accessible
		row_nodes.append(node)

	return row_nodes

func _generate_connections(map: MapData) -> void:
	# For each row (except the last), connect to the next row
	for row_idx in range(map.nodes.size() - 1):
		var current_row = map.nodes[row_idx]
		var next_row = map.nodes[row_idx + 1]

		# Ensure every node in next row is reachable from at least one node
		# and every node in current row connects to at least one node

		var next_row_reached: Array[bool] = []
		for i in range(next_row.size()):
			next_row_reached.append(false)

		# First pass: connect each current node to at least one next node
		for i in range(current_row.size()):
			var node = current_row[i] as MapNodeData

			# Determine reasonable connection targets based on position
			var relative_pos = float(i) / max(1, current_row.size() - 1)
			var target_center = int(relative_pos * (next_row.size() - 1))

			# Connect to 1-3 nearby nodes
			var num_connections = randi_range(1, mini(3, next_row.size()))
			var possible_targets: Array[int] = []

			for j in range(next_row.size()):
				if abs(j - target_center) <= 1:
					possible_targets.append(j)

			# Ensure at least one connection
			if possible_targets.is_empty():
				possible_targets.append(clampi(target_center, 0, next_row.size() - 1))

			possible_targets.shuffle()
			for j in range(mini(num_connections, possible_targets.size())):
				var target = possible_targets[j]
				if target not in node.connections:
					node.connections.append(target)
					next_row_reached[target] = true

		# Second pass: ensure all next row nodes are reachable
		for j in range(next_row.size()):
			if not next_row_reached[j]:
				# Find a current row node to connect from
				var best_source = 0
				var best_dist = 999

				for i in range(current_row.size()):
					var relative_pos = float(i) / max(1, current_row.size() - 1)
					var target_pos = float(j) / max(1, next_row.size() - 1)
					var dist = abs(relative_pos - target_pos)
					if dist < best_dist:
						best_dist = dist
						best_source = i

				var source_node = current_row[best_source] as MapNodeData
				if j not in source_node.connections:
					source_node.connections.append(j)

func _assign_node_types(map: MapData, act: int) -> void:
	# Track what we've placed for balance
	var placed_counts = {
		"elite": 0,
		"evolution_spire": 0,
		"rest_site": 0,
		"trait_shrine": 0,
		"mystery": 0
	}

	var target_elite = 2 + (act - 1)  # More elites in later acts
	var target_spire = 2
	var target_rest = 2
	var target_trait = 1
	var target_mystery = 1

	for row_idx in range(map.nodes.size()):
		var row_nodes = map.nodes[row_idx]

		for node in row_nodes:
			var map_node = node as MapNodeData

			# Special cases
			if row_idx == 0:
				# First row is always combat
				map_node.node_type = Enums.NodeType.COMBAT
				continue

			if row_idx == map.nodes.size() - 1:
				# Last row is always boss
				map_node.node_type = Enums.NodeType.BOSS
				continue

			# Guaranteed rest site option in middle rows
			if row_idx >= REST_GUARANTEED_ROW_MIN and row_idx <= REST_GUARANTEED_ROW_MAX:
				if placed_counts["rest_site"] < target_rest and randf() < 0.5:
					map_node.node_type = Enums.NodeType.REST_SITE
					placed_counts["rest_site"] += 1
					continue

			# Elite restrictions
			if row_idx >= ELITE_MIN_ROW and placed_counts["elite"] < target_elite and randf() < 0.25:
				map_node.node_type = Enums.NodeType.ELITE
				placed_counts["elite"] += 1
				continue

			# Random assignment for other types
			var roll = randf()
			var cumulative = 0.0

			if placed_counts["evolution_spire"] < target_spire and roll < 0.15:
				map_node.node_type = Enums.NodeType.EVOLUTION_SPIRE
				placed_counts["evolution_spire"] += 1
			elif placed_counts["rest_site"] < target_rest and roll < 0.3:
				map_node.node_type = Enums.NodeType.REST_SITE
				placed_counts["rest_site"] += 1
			elif placed_counts["trait_shrine"] < target_trait and roll < 0.4:
				map_node.node_type = Enums.NodeType.TRAIT_SHRINE
				placed_counts["trait_shrine"] += 1
			elif placed_counts["mystery"] < target_mystery and roll < 0.5:
				map_node.node_type = Enums.NodeType.MYSTERY
				placed_counts["mystery"] += 1
			else:
				map_node.node_type = Enums.NodeType.COMBAT

func _assign_enemies(map: MapData, act: int) -> void:
	var basic_enemies = _get_basic_enemies(act)
	var elite_enemies = _get_elite_enemies(act)
	var boss_enemy = _get_boss(act)

	for row in map.nodes:
		for node in row:
			var map_node = node as MapNodeData

			match map_node.node_type:
				Enums.NodeType.COMBAT:
					# 1-3 basic enemies
					var enemy_count = randi_range(1, 2 + act - 1)
					var enemies: Array = []
					for i in range(enemy_count):
						enemies.append(basic_enemies[randi() % basic_enemies.size()])
					map_node.enemies = enemies

				Enums.NodeType.ELITE:
					var enemies: Array = [elite_enemies[randi() % elite_enemies.size()]]
					map_node.enemies = enemies

				Enums.NodeType.BOSS:
					map_node.enemies = [boss_enemy]

func _get_basic_enemies(act: int) -> Array:
	var enemies: Array = []

	# Scavenger
	var scavenger = EnemyData.new()
	scavenger.id = "scavenger"
	scavenger.enemy_name = "Scavenger"
	scavenger.max_hp = 12 + (act * 3)
	scavenger.placeholder_color = Color(0.6, 0.3, 0.2)
	scavenger.food_token_reward_min = 10 + (act * 5)
	scavenger.food_token_reward_max = 15 + (act * 5)

	var attack1 = IntentData.new()
	attack1.intent_type = Enums.IntentType.ATTACK
	attack1.value = 5 + act
	scavenger.intent_pattern = [attack1, attack1]
	enemies.append(scavenger)

	# Venomous Snake
	var snake = EnemyData.new()
	snake.id = "venomous_snake"
	snake.enemy_name = "Venomous Snake"
	snake.max_hp = 10 + (act * 2)
	snake.placeholder_color = Color(0.3, 0.5, 0.3)
	snake.food_token_reward_min = 12 + (act * 4)
	snake.food_token_reward_max = 18 + (act * 4)

	var poison_attack = IntentData.new()
	poison_attack.intent_type = Enums.IntentType.ATTACK
	poison_attack.value = 3 + act
	poison_attack.applies_status = Enums.StatusType.POISON
	poison_attack.status_amount = 2 + act
	snake.intent_pattern = [poison_attack]
	enemies.append(snake)

	# Feral Beast
	var beast = EnemyData.new()
	beast.id = "feral_beast"
	beast.enemy_name = "Feral Beast"
	beast.max_hp = 18 + (act * 4)
	beast.placeholder_color = Color(0.5, 0.35, 0.25)
	beast.food_token_reward_min = 15 + (act * 5)
	beast.food_token_reward_max = 22 + (act * 5)

	var heavy_attack = IntentData.new()
	heavy_attack.intent_type = Enums.IntentType.ATTACK
	heavy_attack.value = 8 + (act * 2)

	var buff = IntentData.new()
	buff.intent_type = Enums.IntentType.BUFF
	buff.value = 2

	beast.intent_pattern = [heavy_attack, buff, heavy_attack]
	enemies.append(beast)

	return enemies

func _get_elite_enemies(act: int) -> Array:
	var enemies: Array = []

	# Alpha Predator
	var alpha = EnemyData.new()
	alpha.id = "alpha_predator"
	alpha.enemy_name = "Alpha Predator"
	alpha.max_hp = 35 + (act * 10)
	alpha.is_elite = true
	alpha.placeholder_color = Color(0.7, 0.5, 0.2)
	alpha.food_token_reward_min = 35 + (act * 10)
	alpha.food_token_reward_max = 50 + (act * 10)

	var fierce_attack = IntentData.new()
	fierce_attack.intent_type = Enums.IntentType.ATTACK
	fierce_attack.value = 10 + (act * 3)

	var multi_attack = IntentData.new()
	multi_attack.intent_type = Enums.IntentType.ATTACK
	multi_attack.value = 5 + act
	multi_attack.hits = 2

	var roar = IntentData.new()
	roar.intent_type = Enums.IntentType.BUFF
	roar.value = 3

	alpha.intent_pattern = [fierce_attack, multi_attack, roar]
	enemies.append(alpha)

	return enemies

func _get_boss(act: int) -> EnemyData:
	var boss = EnemyData.new()
	boss.is_boss = true
	boss.food_token_reward_min = 75 + (act * 25)
	boss.food_token_reward_max = 100 + (act * 25)

	match act:
		1:
			boss.id = "the_lurker"
			boss.enemy_name = "The Lurker"
			boss.max_hp = 60
			boss.placeholder_color = Color(0.4, 0.3, 0.5)

			var strike = IntentData.new()
			strike.intent_type = Enums.IntentType.ATTACK
			strike.value = 12

			var ambush = IntentData.new()
			ambush.intent_type = Enums.IntentType.ATTACK
			ambush.value = 8
			ambush.hits = 2

			var defend = IntentData.new()
			defend.intent_type = Enums.IntentType.DEFEND
			defend.value = 15

			boss.intent_pattern = [strike, ambush, defend]

		2:
			boss.id = "swarm_mother"
			boss.enemy_name = "The Swarm Mother"
			boss.max_hp = 90
			boss.placeholder_color = Color(0.3, 0.5, 0.3)

			var sting = IntentData.new()
			sting.intent_type = Enums.IntentType.ATTACK
			sting.value = 10
			sting.applies_status = Enums.StatusType.POISON
			sting.status_amount = 4

			var swarm = IntentData.new()
			swarm.intent_type = Enums.IntentType.ATTACK
			swarm.value = 4
			swarm.hits = 4

			var buff = IntentData.new()
			buff.intent_type = Enums.IntentType.BUFF
			buff.value = 3

			boss.intent_pattern = [sting, swarm, buff]

		3:
			boss.id = "apex_predator"
			boss.enemy_name = "The Apex Predator"
			boss.max_hp = 150
			boss.placeholder_color = Color(0.6, 0.2, 0.2)

			var devastate = IntentData.new()
			devastate.intent_type = Enums.IntentType.ATTACK
			devastate.value = 25

			var rampage = IntentData.new()
			rampage.intent_type = Enums.IntentType.ATTACK
			rampage.value = 12
			rampage.is_aoe = true

			var empower = IntentData.new()
			empower.intent_type = Enums.IntentType.BUFF
			empower.value = 5

			var defend = IntentData.new()
			defend.intent_type = Enums.IntentType.DEFEND
			defend.value = 20

			boss.intent_pattern = [devastate, rampage, empower, defend]

	return boss
