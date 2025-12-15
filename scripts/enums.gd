class_name Enums
extends RefCounted
## Global enums used throughout the game

## Card rarity levels
enum Rarity {
	COMMON,
	UNCOMMON,
	RARE
}

## Species types for creatures
enum SpeciesType {
	INSECTOID,
	MAMMAL,
	REPTILE,
	AMPHIBIAN,
	AVIAN
}

## Target types for action cards
enum TargetType {
	NONE,           ## No targeting needed (e.g., draw cards)
	FRIENDLY_CREATURE,  ## Target one of your creatures
	ENEMY,          ## Target one enemy
	ALL_ENEMIES,    ## Hits all enemies
	ALL_CREATURES,  ## Hits all friendly creatures
	ALL,            ## Hits everything
	SELF            ## Targets the player directly
}

## Effect types for cards
enum EffectType {
	DAMAGE,         ## Deal damage
	SHIELD,         ## Add temporary shield (clears end of turn)
	ARMOR,          ## Add permanent armor
	HEAL,           ## Restore HP
	DRAW,           ## Draw cards
	ENERGY,         ## Gain energy
	POISON,         ## Apply poison
	STRENGTH,       ## Add strength (bonus damage)
	WEAKNESS,       ## Apply weakness (reduced damage)
	STUN,           ## Skip next action
	SUMMON,         ## Summon a creature
	DISCARD,        ## Discard cards
	EXHAUST_CARD    ## Exhaust a card
}

## Status effect types
enum StatusType {
	SHIELD,         ## Temporary damage absorption (clears end of turn)
	ARMOR,          ## Permanent damage absorption
	POISON,         ## Damage over time, decreases by 1 each turn
	REGENERATION,   ## Heal over time (permanent ability)
	STRENGTH,       ## Bonus attack damage (permanent for combat)
	WEAKNESS,       ## Reduced attack damage (decreases by 1 each turn)
	FLYING,         ## Can only be hit by flying/ranged
	STUNNED         ## Skip next action
}

## Card keywords
enum CardKeyword {
	EXHAUST,        ## Remove from combat when played
	RETAIN,         ## Keep in hand at end of turn
	INNATE          ## Always in opening hand
}

## Map node types
enum NodeType {
	COMBAT,
	ELITE,
	EVOLUTION_SPIRE,
	TRAIT_SHRINE,
	REST_SITE,
	MYSTERY,
	BOSS
}

## Game states
enum GameState {
	MAIN_MENU,
	ARCHETYPE_SELECT,
	MAP,
	COMBAT,
	REWARD,
	EVOLUTION_SPIRE,
	REST_SITE,
	TRAIT_SHRINE,
	GAME_OVER,
	VICTORY
}

## Combat phases
enum CombatPhase {
	COMBAT_START,
	PLAYER_TURN_START,
	PLAYER_ACTION,
	PLAYER_TURN_END,
	ENEMY_TURN,
	COMBAT_END
}

## Intent types for enemies
enum IntentType {
	ATTACK,
	DEFEND,
	BUFF,
	DEBUFF,
	SUMMON,
	SPECIAL
}
