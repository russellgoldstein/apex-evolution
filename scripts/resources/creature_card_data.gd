class_name CreatureCardData
extends CardData
## Data for creature cards that persist on the battlefield

@export var attack: int = 1
@export var max_hp: int = 4
@export var species_types: Array[Enums.SpeciesType] = []

## Innate abilities (always active when creature is in play)
@export_multiline var ability_text: String = ""

## Evolution data
@export var evolution_tier: int = 0
@export var evolution_options: Array = []  # Array of EvolutionData

## Special flags
@export var has_flying: bool = false
@export var has_regeneration: int = 0  ## Regeneration amount (0 = none)

func _init():
	placeholder_color = Color(0.2, 0.5, 0.3)  ## Green-ish for creatures

func is_creature() -> bool:
	return true

func has_species(species: Enums.SpeciesType) -> bool:
	return species in species_types

func get_species_string() -> String:
	var names: Array = []
	for species in species_types:
		match species:
			Enums.SpeciesType.INSECTOID:
				names.append("Insectoid")
			Enums.SpeciesType.MAMMAL:
				names.append("Mammal")
			Enums.SpeciesType.REPTILE:
				names.append("Reptile")
			Enums.SpeciesType.AMPHIBIAN:
				names.append("Amphibian")
			Enums.SpeciesType.AVIAN:
				names.append("Avian")
	return " / ".join(names)

func get_full_description() -> String:
	var parts: Array = []

	# Species types
	if species_types.size() > 0:
		parts.append(get_species_string())

	# Stats
	parts.append("ATK: %d | HP: %d" % [attack, max_hp])

	# Abilities
	if has_flying:
		parts.append("Flying")
	if has_regeneration > 0:
		parts.append("Regeneration %d" % has_regeneration)
	if ability_text:
		parts.append(ability_text)

	return "\n".join(parts)
