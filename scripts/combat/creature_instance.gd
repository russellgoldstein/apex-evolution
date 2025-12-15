class_name CreatureInstance
extends RefCounted
## Runtime instance of a creature with current state

# Preload to ensure class is available
const CreatureCardDataScript = preload("res://scripts/resources/creature_card_data.gd")

var data  # CreatureCardData
var instance_id: int  ## Unique ID for this instance

## Current stats (can differ from base due to buffs/damage)
var current_hp: int
var current_attack: int
var current_max_hp: int

## Status effects: Dictionary of StatusType -> amount
var status_effects: Dictionary = {}

## Position on board (-1 if not on board)
var board_position: int = -1

## Whether this creature is exhausted (died this combat)
var is_exhausted: bool = false

## Evolution state
var evolution_tier: int = 0
var evolved_data  ## Current evolved form (or base if not evolved)

static var _next_id: int = 0

func _init(creature_data) -> void:
	data = creature_data
	evolved_data = creature_data
	instance_id = _next_id
	_next_id += 1

	# Initialize stats from data
	reset_to_full()

func reset_to_full() -> void:
	## Reset to full HP (used at start of run or when returning from exhaustion)
	current_max_hp = evolved_data.max_hp
	current_hp = current_max_hp
	current_attack = evolved_data.attack
	is_exhausted = false
	status_effects.clear()

func reset_for_new_combat() -> void:
	## Called at start of each combat
	## Creatures keep their HP but lose status effects
	status_effects.clear()
	board_position = -1

	# If was exhausted, return at full HP
	if is_exhausted:
		reset_to_full()

func take_damage(amount: int) -> int:
	## Returns actual damage taken after shields/armor
	var remaining_damage = amount

	# First, absorb with shield (temporary)
	if has_status(Enums.StatusType.SHIELD):
		var shield = get_status_amount(Enums.StatusType.SHIELD)
		var absorbed = mini(shield, remaining_damage)
		modify_status(Enums.StatusType.SHIELD, -absorbed)
		remaining_damage -= absorbed

	# Then, absorb with armor (permanent)
	if has_status(Enums.StatusType.ARMOR) and remaining_damage > 0:
		var armor = get_status_amount(Enums.StatusType.ARMOR)
		var absorbed = mini(armor, remaining_damage)
		modify_status(Enums.StatusType.ARMOR, -absorbed)
		remaining_damage -= absorbed

	# Apply remaining damage to HP
	if remaining_damage > 0:
		current_hp = maxi(0, current_hp - remaining_damage)

	return remaining_damage

func heal(amount: int) -> int:
	## Returns actual amount healed
	var old_hp = current_hp
	current_hp = mini(current_max_hp, current_hp + amount)
	return current_hp - old_hp

func get_attack_damage() -> int:
	## Get total attack damage including strength
	var damage = current_attack
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

func process_turn_start() -> void:
	## Called at start of player turn
	# Process regeneration
	if evolved_data.has_regeneration > 0:
		heal(evolved_data.has_regeneration)

func process_turn_end() -> void:
	## Called at end of player turn
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

func is_alive() -> bool:
	return current_hp > 0 and not is_exhausted

func die() -> void:
	## Called when HP reaches 0
	is_exhausted = true
	board_position = -1

func evolve(new_data) -> void:
	## Apply an evolution
	evolved_data = new_data
	evolution_tier += 1

	# Update stats (keep damage ratio)
	var hp_ratio = float(current_hp) / float(current_max_hp) if current_max_hp > 0 else 1.0
	current_max_hp = new_data.max_hp
	current_hp = int(current_max_hp * hp_ratio)
	current_attack = new_data.attack

func get_display_name() -> String:
	return evolved_data.card_name

func has_flying() -> bool:
	return evolved_data.has_flying or has_status(Enums.StatusType.FLYING)
