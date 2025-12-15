class_name IntentData
extends Resource
## Represents a single enemy intent/action

@export var intent_type: Enums.IntentType = Enums.IntentType.ATTACK
@export var value: int = 6  ## Damage amount, shield amount, etc.
@export var hits: int = 1   ## Number of times to hit (for multi-attack)

## For special intents
@export var applies_status: Enums.StatusType = Enums.StatusType.SHIELD
@export var status_amount: int = 0

## For AOE attacks
@export var is_aoe: bool = false

## For summoning
@export var summons_enemy: EnemyData

## Description override
@export var custom_description: String = ""

func get_description() -> String:
	if custom_description:
		return custom_description

	match intent_type:
		Enums.IntentType.ATTACK:
			if is_aoe:
				if hits > 1:
					return "AOE %d x%d" % [value, hits]
				return "AOE %d" % value
			else:
				if hits > 1:
					return "%d x%d" % [value, hits]
				return str(value)
		Enums.IntentType.DEFEND:
			return "Block %d" % value
		Enums.IntentType.BUFF:
			return "Buff"
		Enums.IntentType.DEBUFF:
			return "Debuff"
		Enums.IntentType.SUMMON:
			return "Summon"
		Enums.IntentType.SPECIAL:
			return "???"
		_:
			return "?"

func get_icon_name() -> String:
	match intent_type:
		Enums.IntentType.ATTACK:
			return "attack"
		Enums.IntentType.DEFEND:
			return "defend"
		Enums.IntentType.BUFF:
			return "buff"
		Enums.IntentType.DEBUFF:
			return "debuff"
		Enums.IntentType.SUMMON:
			return "summon"
		_:
			return "unknown"
