class_name ActionCardData
extends CardData
## Data for action cards (spells/maneuvers)

@export var target_type: Enums.TargetType = Enums.TargetType.FRIENDLY_CREATURE
@export var requires_creature: bool = true  ## If true, can only play when you have creatures on board
@export var effects: Array = []  # Array of EffectData

## Reference to upgraded version of this card
@export var upgraded_version: Resource  # ActionCardData

## For creature summon cards
@export var summons_creature: Resource  # CreatureCardData

func _init():
	placeholder_color = Color(0.3, 0.3, 0.6)  ## Blue-ish for actions

func is_action() -> bool:
	return true

func is_upgraded() -> bool:
	return upgraded_version == null and id.ends_with("+")

func get_full_description() -> String:
	var parts: Array = []

	# Keywords
	for keyword in keywords:
		match keyword:
			Enums.CardKeyword.EXHAUST:
				parts.append("[Exhaust]")
			Enums.CardKeyword.RETAIN:
				parts.append("[Retain]")
			Enums.CardKeyword.INNATE:
				parts.append("[Innate]")

	# Target requirement
	if requires_creature:
		match target_type:
			Enums.TargetType.FRIENDLY_CREATURE:
				parts.append("Target your creature:")
			Enums.TargetType.ENEMY:
				parts.append("Target enemy:")

	# Effect descriptions
	for effect in effects:
		parts.append(effect.get_description())

	# Override with manual description if provided
	if description:
		return description

	return "\n".join(parts)

func can_play(has_creatures_on_board: bool) -> bool:
	if requires_creature and not has_creatures_on_board:
		return false
	return true
