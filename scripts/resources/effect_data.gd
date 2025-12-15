class_name EffectData
extends Resource
## Represents a single effect that a card can have

@export var type: Enums.EffectType = Enums.EffectType.DAMAGE
@export var value: int = 0
@export var target_override: Enums.TargetType = Enums.TargetType.NONE  ## If set, overrides card's target type

## For conditional effects
@export var condition: String = ""  ## e.g., "creature_below_half_hp", "has_poison"

## For scaling effects
@export var scales_with: String = ""  ## e.g., "creature_attack", "poison_stacks"
@export var scale_multiplier: float = 1.0

func get_description() -> String:
	match type:
		Enums.EffectType.DAMAGE:
			return "Deal %d damage" % value
		Enums.EffectType.SHIELD:
			return "Gain %d Shield" % value
		Enums.EffectType.ARMOR:
			return "Gain %d Armor" % value
		Enums.EffectType.HEAL:
			return "Heal %d HP" % value
		Enums.EffectType.DRAW:
			return "Draw %d card%s" % [value, "s" if value > 1 else ""]
		Enums.EffectType.ENERGY:
			return "Gain %d Energy" % value
		Enums.EffectType.POISON:
			return "Apply %d Poison" % value
		Enums.EffectType.STRENGTH:
			return "Gain %d Strength" % value
		Enums.EffectType.WEAKNESS:
			return "Apply %d Weakness" % value
		Enums.EffectType.STUN:
			return "Stun"
		_:
			return "Unknown effect"
