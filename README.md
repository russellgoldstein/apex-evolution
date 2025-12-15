# Apex Evolution

A roguelike deckbuilder built in Godot 4 where you evolve creatures from hatchlings into apex predators.

## Getting Started

1. Open the project in Godot 4.2+
2. Run the project (F5)
3. Click "New Game" and select an archetype

## Project Structure

```
apex-evolution/
├── project.godot          # Godot project file
├── scenes/
│   ├── main.tscn          # Entry point
│   ├── screens/           # Game screens (title, map, combat, etc.)
│   ├── combat/            # Combat UI components
│   ├── map/               # Map components
│   └── ui/                # Shared UI components
├── scripts/
│   ├── autoload/          # Global singletons
│   ├── resources/         # Data class definitions
│   ├── combat/            # Combat logic
│   ├── cards/             # Card logic
│   ├── map/               # Map generation
│   ├── screens/           # Screen controllers
│   └── ui/                # UI controllers
└── resources/             # Game data (.tres files)
```

## Core Features

- **Turn-based card combat** with persistent creatures
- **Creature evolution system** with branching upgrade paths
- **Procedural maps** with branching paths (Slay the Spire style)
- **3 acts** with increasing difficulty
- **5 species types** with synergy potential
- **Trait system** for build-defining passive bonuses
- **Lair mechanic** - Lead Creature starts each combat in play

## How to Play

1. **Select an Archetype** - Each starts with a unique creature and trait
2. **Navigate the Map** - Choose your path through combat, shops, and rest sites
3. **Combat** - Play cards to make your creatures attack and defend
4. **Evolve** - Spend Food Tokens at Evolution Spires to power up creatures
5. **Defeat the Boss** - Survive all 3 acts to win

## Combat Controls

- **Click card** to play (some require targeting)
- **Click creature/enemy** to select target
- **Right-click** to cancel targeting
- **End Turn button** to pass to enemies

## Development Status

This is a functional prototype with:
- Complete gameplay loop (title → archetype → map → combat → rewards → repeat)
- 3 starting archetypes (Insectoid, Mammal, Reptile)
- Basic card pool (~10 action cards)
- Basic enemy pool with scaling difficulty
- 3 bosses (one per act)
- Evolution, trait, and shop systems

### Future Development
- More cards, enemies, traits
- Save/load system
- Unlockable archetypes (Amphibian, Avian)
- Visual polish and animations
- Audio integration
- Mobile export configuration

## Tech Stack

- **Engine**: Godot 4.2+
- **Language**: GDScript
- **Target Platforms**: Web, iOS, Android (future)

## License

[Add your license here]
