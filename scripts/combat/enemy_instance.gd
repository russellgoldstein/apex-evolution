class_name EnemyInstance
extends RefCounted
## Runtime instance of an enemy with current state

var data: EnemyData
var instance_id: int

## Current stats
var current_hp: int
var current_max_hp: int

## Status effects
var status_effects: Dictionary = {}

## Intent tracking
var current_intent_index: int = 0
var current_intent: IntentData

## Position in enemy lineup
var position: int = 0

static var _next_id: int = 0

func _init(enemy_data: EnemyData) -> void:
	data = enemy_data
	instance_id = _next_id
	_next_id += 1

	current_max_hp = data.max_hp
	current_hp = current_max_hp

	# Set initial intent
	if data.intent_pattern.size() > 0:
		current_intent = data.intent_pattern[0]

func take_damage(amount: int) -> int:
	## Returns actual damage taken
	var remaining_damage = amount

	# Absorb with shield
	if has_status(Enums.StatusType.SHIELD):
		var shield = get_status_amount(Enums.StatusType.SHIELD)
		var absorbed = mini(shield, remaining_damage)
		modify_status(Enums.StatusType.SHIELD, -absorbed)
		remaining_damage -= absorbed

	# Absorb with armor
	if has_status(Enums.StatusType.ARMOR) and remaining_damage > 0:
		var armor = get_status_amount(Enums.StatusType.ARMOR)
		var absorbed = mini(armor, remaining_damage)
		modify_status(Enums.StatusType.ARMOR, -absorbed)
		remaining_damage -= absorbed

	# Apply to HP
	if remaining_damage > 0:
		current_hp = maxi(0, current_hp - remaining_damage)

	return remaining_damage

func heal(amount: int) -> int:
	var old_hp = current_hp
	current_hp = mini(current_max_hp, current_hp + amount)
	return current_hp - old_hp

func get_attack_damage() -> int:
	var damage = current_intent.value if current_intent else 0
	if has_status(Enums.StatusType.STRENGTH):
		damage += get_status_amount(Enums.StatusType.STRENGTH)
	if has_status(Enums.StatusType.WEAKNESS):
		damage = maxi(0, damage - get_status_amount(Enums.StatusType.WEAKNESS))
	return damage

func has_status(status_type: Enums.StatusType) -> bool:
	return status_effects.has(status_type) and status_effects[status_type] > 0

func get_status_amount(status_type: Enums.StatusType) -> int:
	return status_effects.get(status_type, 0)

func modify_status(status_type: Enums.StatusType, amount: int) -> void:
	var current = get_status_amount(status_type)
	var new_amount = maxi(0, current + amount)
	if new_amount > 0:
		status_effects[status_type] = new_amount
	elif status_effects.has(status_type):
		status_effects.erase(status_type)

func set_status(status_type: Enums.StatusType, amount: int) -> void:
	if amount > 0:
		status_effects[status_type] = amount
	elif status_effects.has(status_type):
		status_effects.erase(status_type)

func advance_intent() -> void:
	## Move to next intent in pattern
	if data.intent_pattern.size() == 0:
		return

	current_intent_index = (current_intent_index + 1) % data.intent_pattern.size()
	current_intent = data.intent_pattern[current_intent_index]

func process_turn_start() -> void:
	## Called at start of enemy turn
	pass

func process_turn_end() -> void:
	## Called at end of enemy turn
	# Clear shield
	set_status(Enums.StatusType.SHIELD, 0)

	# Process poison
	if has_status(Enums.StatusType.POISON):
		var poison = get_status_amount(Enums.StatusType.POISON)
		take_damage(poison)
		modify_status(Enums.StatusType.POISON, -1)

	# Reduce weakness
	if has_status(Enums.StatusType.WEAKNESS):
		modify_status(Enums.StatusType.WEAKNESS, -1)

	# Advance to next intent
	advance_intent()

func is_alive() -> bool:
	return current_hp > 0

func is_stunned() -> bool:
	return has_status(Enums.StatusType.STUNNED)

func has_flying() -> bool:
	return data.has_flying or has_status(Enums.StatusType.FLYING)

func has_piercing() -> bool:
	return data.has_piercing

func get_display_name() -> String:
	return data.enemy_name
