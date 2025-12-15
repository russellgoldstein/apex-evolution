class_name ArchetypeData
extends Resource
## Starting archetype data

@export var id: String = ""
@export var archetype_name: String = ""
@export_multiline var description: String = ""

## Starting creature
@export var starting_creature: Resource  # CreatureCardData

## Starting deck (action cards)
@export var starting_deck: Array = []  # Array of ActionCardData

## Starting trait
@export var starting_trait: Resource  # TraitData

## Visual
@export var portrait: Texture2D
@export var color: Color = Color.WHITE

## Unlock condition
@export var unlocked_by_default: bool = true
@export var unlock_condition: String = ""  ## e.g., "win_with_insectoid"

func get_playstyle_hint() -> String:
	match id:
		"insectoid":
			return "Balanced, good for learning"
		"mammal":
			return "Aggressive, rewards quick kills"
		"reptile":
			return "Defensive, attrition-based"
		"amphibian":
			return "Control, status effects"
		"avian":
			return "Card advantage, evasion"
		_:
			return ""
