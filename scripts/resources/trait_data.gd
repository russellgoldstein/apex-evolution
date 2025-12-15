class_name TraitData
extends Resource
## Data for passive trait upgrades

enum TraitTrigger {
	PASSIVE,            ## Always active
	ON_COMBAT_START,    ## Triggers at start of each combat
	ON_TURN_START,      ## Triggers at start of each player turn
	ON_TURN_END,        ## Triggers at end of each player turn
	ON_CARD_PLAY,       ## Triggers when any card is played
	ON_CREATURE_PLAY,   ## Triggers when a creature is played
	ON_ACTION_PLAY,     ## Triggers when an action is played
	ON_DAMAGE_DEALT,    ## Triggers when dealing damage
	ON_DAMAGE_TAKEN,    ## Triggers when taking damage
	ON_CREATURE_DEATH,  ## Triggers when a creature dies
	ON_ENEMY_DEATH,     ## Triggers when an enemy dies
	ON_HEAL            ## Triggers when healing occurs
}

enum TraitCategory {
	SPECIES,    ## Rewards creature type focus
	DECK,       ## Modifies card/deck mechanics
	COMBAT,     ## Affects battle mechanics
	HYBRID      ## Rewards type merging
}

@export var id: String = ""
@export var trait_name: String = ""
@export_multiline var description: String = ""
@export var category: TraitCategory = TraitCategory.COMBAT
@export var trigger: TraitTrigger = TraitTrigger.PASSIVE

## Trait icon
@export var icon: Texture2D
@export var icon_color: Color = Color.WHITE

## Conditions for the trait to apply
## e.g., {"species": "INSECTOID"} or {"creature_count_min": 2}
@export var conditions: Dictionary = {}

## Effect parameters
## e.g., {"stat": "max_hp", "value": 2} or {"draw": 1}
@export var effect_params: Dictionary = {}

## Shop cost if purchasable
@export var shop_cost: int = 150

## Rarity affects how often it appears in choices
@export var rarity: Enums.Rarity = Enums.Rarity.COMMON

func get_category_string() -> String:
	match category:
		TraitCategory.SPECIES:
			return "Species"
		TraitCategory.DECK:
			return "Deck"
		TraitCategory.COMBAT:
			return "Combat"
		TraitCategory.HYBRID:
			return "Hybrid"
		_:
			return "Trait"
