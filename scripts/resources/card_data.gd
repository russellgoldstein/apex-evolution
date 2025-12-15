class_name CardData
extends Resource
## Base class for all cards (creatures and actions)

@export var id: String = ""
@export var card_name: String = ""
@export_multiline var description: String = ""
@export var energy_cost: int = 1
@export var rarity: Enums.Rarity = Enums.Rarity.COMMON
@export var keywords: Array[Enums.CardKeyword] = []
@export var card_art: Texture2D

## Color for placeholder cards when no art is provided
@export var placeholder_color: Color = Color.GRAY

func has_keyword(keyword: Enums.CardKeyword) -> bool:
	return keyword in keywords

func get_full_description() -> String:
	var parts: Array[String] = []

	# Add keywords at the top
	for keyword in keywords:
		match keyword:
			Enums.CardKeyword.EXHAUST:
				parts.append("[Exhaust]")
			Enums.CardKeyword.RETAIN:
				parts.append("[Retain]")
			Enums.CardKeyword.INNATE:
				parts.append("[Innate]")

	if description:
		parts.append(description)

	return "\n".join(parts)

func is_creature() -> bool:
	return false

func is_action() -> bool:
	return false
