class_name EvolutionData
extends Resource
## Data for a single evolution option

enum EvolutionType {
	STAT,       ## Pure stat increase
	ABILITY,    ## Gain a new ability
	TYPE_MERGE  ## Gain a new species type
}

@export var id: String = ""
@export var evolution_name: String = ""
@export_multiline var description: String = ""
@export var evolution_type: EvolutionType = EvolutionType.STAT

## The resulting creature card after evolution
@export var result_creature: Resource  # CreatureCardData

## Cost in Food Tokens
@export var cost: int = 50

## Visual preview
@export var preview_art: Texture2D

func get_type_string() -> String:
	match evolution_type:
		EvolutionType.STAT:
			return "Stat Evolution"
		EvolutionType.ABILITY:
			return "Ability Evolution"
		EvolutionType.TYPE_MERGE:
			return "Type Merge"
		_:
			return "Evolution"
