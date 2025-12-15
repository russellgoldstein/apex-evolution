class_name EnemyData
extends Resource
## Data for enemy combatants

@export var id: String = ""
@export var enemy_name: String = ""
@export var max_hp: int = 20
@export var species_type: Enums.SpeciesType = Enums.SpeciesType.MAMMAL

## Visual
@export var enemy_art: Texture2D
@export var placeholder_color: Color = Color(0.6, 0.2, 0.2)  ## Red-ish for enemies

## Intent pattern - cycles through these
@export var intent_pattern: Array[IntentData] = []

## Special abilities
@export var has_flying: bool = false
@export var has_piercing: bool = false  ## Attacks player directly
@export var is_elite: bool = false
@export var is_boss: bool = false

## Rewards
@export var food_token_reward_min: int = 15
@export var food_token_reward_max: int = 25

func get_random_reward() -> int:
	return randi_range(food_token_reward_min, food_token_reward_max)
