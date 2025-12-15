# Apex Evolution: Game Design Document v2.0

## 1. Core Concept & Objective

Apex Evolution is a single-player, run-based roguelike deckbuilder. Players begin with a single basic creature and a small deck of action cards. The objective is to navigate a branching map across three acts, strategically evolving creatures, building a synergistic deck, and acquiring passive Traits to defeat the final boss.

The core fantasy: **grow a creature from a fragile hatchling into your personalized apex predator.**

---

## 2. Player Resources

### 2.1 Player Health (HP)
- The player has a primary HP pool (starting value: **50 HP**).
- Players take damage **only when no creatures are on the battlefield**.
- If player HP reaches 0, the run ends.
- Player HP persists between combats and does not naturally regenerate.

### 2.2 Energy (Tactical Resource)
- Used to play cards during combat.
- Starts at **3 Energy** per turn (can be increased via Traits/upgrades).
- Fully refills at the start of each turn.
- Unspent Energy does not carry over.

### 2.3 Food Tokens (FT) (Strategic Resource)
- The "gold" of Apex Evolution.
- Earned by winning combats (scaling with difficulty).
- Spent at Evolution Spire (Shop) nodes for:
  1. **Evolving creatures** (major investment)
  2. **Purchasing new cards** (Action or Creature)
  3. **Removing cards** from your deck
  4. **Buying Traits**
  5. **Healing** creatures or player HP

---

## 3. Card Types

### 3.1 Creature Cards
Creatures are the core of your strategy. They persist on the battlefield once played and automatically protect the player from enemy attacks.

**Key Properties:**
- **Cost:** Energy cost to play from hand (typically 1-3)
- **Attack (ATK):** Damage dealt when attacking
- **Health (HP):** Damage capacity; reduced by enemy attacks
- **Species Type:** Classification affecting Trait/card synergies (e.g., Insectoid, Mammal)
- **Abilities:** Special effects (acquired through evolution)

**Creature Limits:**
- **Deck Limit:** Maximum of **4 Creature Cards** in your deck
- **Board Limit:** Maximum of **3 creatures** on the battlefield simultaneously
- If you draw a creature while at board limit, it remains in hand for future use

**The Lair (Starting Creature):**
- At the start of each combat, your designated **Lead Creature** begins in play automatically (no energy cost).
- The Lead Creature enters at its **current HP** (damage persists between combats).
- You designate your Lead Creature outside of combat; it can be changed at Rest Sites or Shops.

**Creature Death & Exhaustion:**
- When a creature's HP reaches 0, it becomes **Exhausted**.
- Exhausted creatures are removed from the current combat entirely (cannot be redrawn).
- At the start of the **next combat**, exhausted creatures return to your deck at **full HP**.
- This creates tactical decisions: sometimes sacrificing a damaged creature to reset its HP is advantageous.

**Creature Healing:**
- Creatures that survive combat retain their current HP (persistent damage).
- Healing sources:
  - Rest Sites (heal all creatures for 50% of max HP)
  - Shop (pay FT to fully heal a creature)
  - Certain Traits (e.g., "Regeneration")
  - Healing Action Cards

### 3.2 Action Cards
Actions are single-use cards that provide attacks, defense, utility, and special effects.

**Categories:**

**A. Creature-Targeted Actions** (require a creature on the battlefield)
- Target one of your creatures to perform an effect
- Examples:
  - *Quick Bite (1 Energy):* Target creature deals 2 damage to an enemy.
  - *Defensive Stance (1 Energy):* Target creature gains 5 Shield.
  - *Frenzy (2 Energy):* Target creature attacks all enemies for its ATK value.

**B. Universal Actions** (no creature required)
- Provide effects independent of board state
- Ensures you always have playable options
- Examples:
  - *Falling Rocks (1 Energy):* Deal 4 damage to a random enemy.
  - *Adrenaline Rush (1 Energy):* Draw 2 cards.
  - *Forage (0 Energy):* Gain 1 Energy this turn. Exhaust.
  - *Primal Roar (2 Energy):* All enemies lose 1 ATK this combat.

**C. Creature Summon Actions** (special)
- Temporary creatures that last one combat
- Don't count toward your 4-creature deck limit
- Examples:
  - *Spawn Hatchling (1 Energy):* Summon a 1/1 Hatchling. Exhaust.

**Card Keywords:**
- **Exhaust:** Remove from deck for remainder of combat (not just discard)
- **Retain:** Card stays in hand at end of turn instead of discarding
- **Innate:** Always appears in opening hand

### 3.3 Starting Deck Composition
- **1 Creature Card:** Basic starter creature (e.g., Infant Insectoid - 1 ATK / 4 HP)
- **8 Action Cards:**
  - 4x *Strike (1 Energy):* Target creature deals 3 damage.
  - 3x *Defend (1 Energy):* Target creature gains 4 Shield.
  - 1x *Adrenaline Rush (1 Energy):* Draw 2 cards. *(Universal)*

---

## 4. Species Types & Synergies

### 4.1 Species Types (5 Base Types)

| Type | Theme | Typical Strengths |
|------|-------|-------------------|
| **Insectoid** | Swarm, poison, numbers | Multi-creature synergies, Poison |
| **Mammal** | Aggression, pack tactics | High ATK, ally buffs |
| **Reptile** | Durability, patience | High HP, regeneration, Poison |
| **Amphibian** | Adaptation, control | Regeneration, status effects |
| **Avian** | Speed, evasion | Flying, extra card draw |

### 4.2 Type Synergies
- **Traits** often reference species types (e.g., "All Insectoid creatures gain +1 ATK")
- **Action Cards** may require or benefit specific types
- **Type Merging:** Through evolution, creatures can gain additional types
  - A "Flying Beetle" might be both Insectoid and Avian
  - Qualifies for synergies of **both** types
  - Creates powerful cross-type builds

---

## 5. Combat System

### 5.1 Combat Setup
1. Your **Lead Creature** enters the Lair (battlefield) automatically at current HP
2. Your deck (remaining creatures + actions) is shuffled
3. Draw opening hand of **5 cards**
4. Enemy intents are displayed

### 5.2 Turn Structure

**Player Turn:**
1. Gain Energy (default: 3)
2. Draw cards (default: 5, or remaining deck)
3. Play cards in any order:
   - Play creatures from hand (pay Energy cost)
   - Play actions (pay Energy cost, select targets)
   - Creatures on board can be targeted by action cards
4. End turn (discard remaining Action Cards; Creature Cards in hand are retained)

**Enemy Turn:**
1. Enemies execute telegraphed intents
2. Enemies target **creatures first** (leftmost creature by default)
3. If no creatures on board, enemies target the **player directly**
4. Some enemies have special targeting (AOE, "Piercing" to hit player, etc.)

### 5.3 Targeting Rules

**Player Targeting:**
- Creature-targeted actions: Select one of your creatures, then (if applicable) select an enemy
- Universal actions: Select enemy or no target (depending on card)
- Attacking: Your creature deals damage to selected enemy

**Enemy Targeting:**
- **Default:** Enemies attack the **leftmost creature** on your board
- **No Creatures:** Enemies attack the player directly
- **Special Abilities:**
  - *AOE:* Hits all creatures
  - *Piercing:* Bypasses creatures, hits player directly
  - *Random:* Targets random creature

### 5.4 Combat Resolution
- Combat ends when all enemies are defeated
- **Rewards:**
  - Food Tokens (FT)
  - Card reward: Choose 1 of 3 Action Cards to add to deck (can skip)
- Surviving creatures retain current HP for next combat

---

## 6. Status Effects

| Status | Effect | Duration |
|--------|--------|----------|
| **Shield** | Absorbs damage before HP. | Until end of turn (temporary) |
| **Armor** | Absorbs damage before HP. | Permanent until depleted |
| **Poison** | Takes X damage at end of turn. Poison decreases by 1 each turn. | Until reduced to 0 |
| **Regeneration X** | Heals X HP at start of turn. | Permanent (creature ability) |
| **Strength** | +X damage on attacks. | Permanent for combat |
| **Weakness** | -X damage on attacks (min 0). | Decreases by 1 each turn |
| **Flying** | Can only be targeted by enemies with Flying or Ranged. | Permanent (creature ability) |
| **Stunned** | Skips next action. | 1 turn |

---

## 7. Evolution System

Evolution is the core progression mechanic. At Evolution Spire nodes, you permanently upgrade a Creature Card.

### 7.1 Evolution Process
1. Select a creature to evolve
2. Pay the FT cost (scales with evolution tier)
3. Choose 1 of 3 evolution paths:
   - **Stat Evolution:** Significant ATK/HP increase
   - **Ability Evolution:** Gain a powerful new ability
   - **Type Merge:** Gain an additional species type + minor ability

### 7.2 Evolution Tiers
Each creature can evolve multiple times, progressing through tiers:

| Tier | Example (Insectoid path) | Typical Cost |
|------|--------------------------|--------------|
| **Tier 0** | Infant Insectoid (1/4) | Starting |
| **Tier 1** | Armored Beetle (1/6) | 50 FT |
| **Tier 2** | Bombardier Beetle (2/6 + ability) | 100 FT |
| **Tier 3** | Apex Scarab (3/8 + ability) | 175 FT |

### 7.3 Evolution Example

**Evolving Armored Beetle (Tier 1):**

| Choice | Result | New Stats | New Ability |
|--------|--------|-----------|-------------|
| **A. Stat** | Rhino Beetle | 3 ATK / 8 HP | — |
| **B. Ability** | Bombardier Beetle | 2 ATK / 6 HP | *"When played, deal 3 damage to all enemies."* |
| **C. Type Merge** | Scarab Monarch | 2 ATK / 6 HP | Gains **Avian** type. *"Flying."* |

- Card art and name update to reflect the evolution
- Evolution choices are **procedurally varied** each run

---

## 8. Traits (Passive Upgrades)

Traits are permanent passive bonuses that define your build. They create the "Hades/Balatro" feeling of run-defining power spikes.

### 8.1 Trait Acquisition
- **Elite Combat Reward:** Guaranteed Trait choice after victory
- **Trait Nodes:** Free "Choose 1 of 3" Trait selection
- **Shop Purchase:** Buy specific Traits for FT

### 8.2 Trait Categories

**Species Traits** (reward creature type focus)
- *Chitinous Plating:* Insectoid creatures have +2 max HP.
- *Pack Hunter:* When you have 2+ Mammal creatures in play, all Mammals gain +1 ATK.
- *Cold-Blooded:* Reptile creatures take 1 less damage from all sources.

**Deck Traits** (modify card mechanics)
- *Rapid Incubation:* Draw 1 extra card at start of each turn.
- *Metabolic Efficiency:* Start each combat with +1 Energy (4 total).
- *Predator's Instinct:* Your first Attack card each turn costs 0.

**Combat Traits** (affect battle mechanics)
- *Territorial:* Your Lead Creature deals +2 damage on its first attack each combat.
- *Cornered Beast:* Creatures below 50% HP gain +2 ATK.
- *Toxic Blood:* When a creature takes damage, the attacker gains 1 Poison.

**Hybrid Traits** (reward type merging)
- *Chimeric Vigor:* Creatures with 2+ types have +3 max HP.
- *Adaptive Genetics:* Creatures with 2+ types gain Regeneration 1.

### 8.3 Trait Limit
- No hard limit on Traits
- Expect to acquire **6-10 Traits** per successful run
- Synergy discovery is key to powerful builds

---

## 9. Map Structure

### 9.1 Overall Structure
- **3 Acts**, each ending with a Boss
- **~15 nodes per act** with branching paths
- Player chooses path; cannot backtrack

### 9.2 Node Types

| Node | Icon | Description | Reward |
|------|------|-------------|--------|
| **Combat** | ⚔️ | Standard enemy encounter | FT + Card choice |
| **Elite** | 💀 | Difficult enemy with enhanced abilities | More FT + Card choice + **Trait** |
| **Evolution Spire** | 🧬 | Shop: Evolve, buy cards, remove cards, heal | — |
| **Trait Shrine** | ✨ | Free Trait selection (1 of 3) | **Trait** |
| **Rest Site** | 🔥 | Choose: Heal OR Upgrade a card OR Change Lead Creature | — |
| **Mystery** | ❓ | Random event (risk/reward) | Varies |
| **Boss** | 👑 | Act boss; mandatory | Large FT + Rare card + **Trait** |

### 9.3 Node Distribution (per Act)
- Combat: 7-8
- Elite: 2-3
- Evolution Spire: 2
- Trait Shrine: 1-2
- Rest Site: 2-3
- Mystery: 1-2
- Boss: 1

### 9.4 Act Progression

| Act | Theme | Enemy Difficulty | Boss |
|-----|-------|------------------|------|
| **Act 1: The Shallows** | Tutorial/establishment | Low | The Lurker |
| **Act 2: The Depths** | Build refinement | Medium | The Swarm Mother |
| **Act 3: The Apex** | Final challenge | High | The Apex Predator |

---

## 10. Rest Site Options

At Rest Sites, choose **one** of the following:

| Option | Effect |
|--------|--------|
| **Rest** | Heal player for 30% max HP. Heal all creatures for 50% max HP. |
| **Train** | Upgrade one card permanently (improved stats or reduced cost). |
| **Reorganize** | Change your designated Lead Creature. |

---

## 11. Card Upgrades

Cards can be upgraded at Rest Sites (Train option) or occasionally at Shops.

### 11.1 Upgrade Effects

**Action Cards:**
- Cost reduction (-1 Energy)
- Effect increase (+damage, +Shield, etc.)
- Added effect (e.g., "Draw 1 card")

**Creature Cards:**
- +1 ATK or +2 HP
- Cost reduction (-1 Energy)
- Note: Evolution is the primary creature upgrade path; card upgrades are minor buffs

### 11.2 Upgrade Examples

| Card | Base | Upgraded |
|------|------|----------|
| Strike | 1 Energy: Deal 3 damage | 1 Energy: Deal **5** damage |
| Defend | 1 Energy: Gain 4 Shield | **0 Energy:** Gain 4 Shield |
| Quick Bite | 1 Energy: Deal 2 damage | 1 Energy: Deal 2 damage. **Draw 1.** |

---

## 12. Starting Archetypes

Each run begins with a choice of starting archetype, providing different strategic foundations:

### 12.1 The Insectoid (Default/Starter)
- **Starting Creature:** Infant Insectoid (1 ATK / 4 HP)
- **Starting Relic/Trait:** *Compound Eyes* - At the start of combat, Scry 2 (look at top 2 cards, reorder or discard).
- **Playstyle:** Balanced, good for learning

### 12.2 The Mammal
- **Starting Creature:** Wolf Pup (2 ATK / 3 HP)
- **Starting Trait:** *Bloodlust* - After killing an enemy, your creatures gain +1 Strength this combat.
- **Playstyle:** Aggressive, rewards quick kills

### 12.3 The Reptile
- **Starting Creature:** Hatchling Lizard (1 ATK / 6 HP)
- **Starting Trait:** *Thick Scales* - Your Lead Creature starts each combat with 3 Armor.
- **Playstyle:** Defensive, attrition-based

### 12.4 The Amphibian (Unlockable)
- **Starting Creature:** Tadpole (0 ATK / 5 HP, Regeneration 1)
- **Starting Trait:** *Adaptive Skin* - At the start of each turn, gain 1 Shield for each status effect on enemies.
- **Playstyle:** Control, status effects

### 12.5 The Avian (Unlockable)
- **Starting Creature:** Fledgling (1 ATK / 2 HP, Flying)
- **Starting Trait:** *Tailwind* - Draw 1 extra card each turn.
- **Playstyle:** Card advantage, evasion

---

## 13. Enemy Design Principles

### 13.1 Intent System
- Enemies display their **intent** at the start of each turn
- Intent shows: action type + value (e.g., "Attack 8", "Buff", "Defend")
- Allows strategic counterplay

### 13.2 Enemy Types

**Basic Enemies:**
- Simple attack patterns
- Low HP, predictable
- Examples: Prey creatures, basic predators

**Elite Enemies:**
- Complex patterns, multiple phases
- May summon minions
- Special abilities (Piercing, AOE, etc.)

**Bosses:**
- Multi-phase fights
- Unique mechanics per boss
- Test specific build aspects

### 13.3 Example Enemies

| Enemy | HP | Pattern |
|-------|-----|---------|
| **Scavenger** | 12 | Alternates: Attack 6 → Attack 6 → Defend (gain 8 Shield) |
| **Venomous Snake** | 18 | Attack 4 + Apply 3 Poison → Attack 8 |
| **Territorial Beast** | 35 | Attack 12 (Piercing - hits player) → AOE 6 → Buff (+3 Strength) |

---

## 14. Economy & Pacing

### 14.1 Food Token (FT) Economy

| Source | FT Earned |
|--------|-----------|
| Basic Combat | 15-25 |
| Elite Combat | 35-50 |
| Boss | 75-100 |
| Mystery Events | 0-30 (variable) |

| Expense | FT Cost |
|---------|---------|
| Tier 1 Evolution | 50 |
| Tier 2 Evolution | 100 |
| Tier 3 Evolution | 175 |
| Common Card | 30-50 |
| Uncommon Card | 60-90 |
| Rare Card | 100-150 |
| Card Removal | 50 (increases each use) |
| Heal Creature (full) | 25 |
| Heal Player (30% HP) | 30 |
| Trait | 120-180 |

### 14.2 Expected Run Progression
- **Act 1:** Establish deck, 1-2 evolutions, 2-3 Traits
- **Act 2:** Refine build, 1-2 evolutions, 3-4 Traits
- **Act 3:** Maximize power, 1 evolution, 2-3 Traits
- **Total:** 3-5 evolutions, 7-10 Traits, ~25 cards in deck

---

## 15. Victory & Unlocks

### 15.1 Victory Condition
- Defeat the Act 3 Boss (The Apex Predator)
- Run ends; score calculated based on:
  - Remaining HP
  - Food Tokens
  - Evolution tiers achieved
  - Traits collected
  - Cards played

### 15.2 Meta Progression (Between Runs)
- **Unlock new Starting Archetypes** (win with specific types)
- **Unlock new Cards** for card pool (appear in rewards)
- **Unlock new Traits** for Trait pool
- **Unlock new Evolutions** for evolution choices
- **Ascension Levels:** Harder difficulty modifiers (like Slay the Spire)

---

## 16. Example Turn of Play

**Situation:** Act 1 combat. You have a Tier 1 Armored Beetle (1 ATK / 6 HP, currently at 4 HP) as Lead Creature. Facing two Scavengers (12 HP each).

**Setup:**
- Armored Beetle enters the Lair at 4 HP
- Draw 5 cards: Strike, Strike, Defend, Quick Bite, Adrenaline Rush
- Enemy intent: Scavenger A will Attack 6, Scavenger B will Attack 6
- You have 3 Energy

**Turn 1:**
1. Play Defend (1 Energy) → Target Armored Beetle → It gains 4 Shield
2. Play Strike (1 Energy) → Target Armored Beetle → It deals 3 damage to Scavenger A (9 HP remaining)
3. Play Quick Bite (1 Energy) → Target Armored Beetle → It deals 2 damage to Scavenger A (7 HP remaining)
4. End turn. 0 Energy remaining. Discard Adrenaline Rush and remaining Strike.

**Enemy Turn:**
- Scavenger A attacks Armored Beetle for 6 → Shield absorbs 4, Beetle takes 2 (now at 2 HP)
- Scavenger B attacks Armored Beetle for 6 → Beetle takes 6, dies (0 HP)
- Armored Beetle becomes **Exhausted** (removed from this combat, returns next fight at full HP)

**Turn 2:**
- No creatures on board!
- Draw 5 cards: Strike, Defend, Defend, Falling Rocks, Strike
- Enemy intent: Both Scavengers will Attack 6 (targeting YOU now)
- You have 3 Energy
- Must play Universal cards or survive until you draw another creature

This example shows the tension of creature management and the risk of losing board presence.

---

## 17. Design Pillars Summary

1. **Evolution as Identity:** Your creatures are personal; watching them transform is the emotional hook.

2. **Tactical Resource Tension:** Energy forces hard choices each turn; FT forces hard choices each shop.

3. **Creature-Centric Combat:** Creatures are your lifeline, not disposable assets. Protect them.

4. **Build Diversity:** Species types, Traits, and evolution paths create distinct run identities.

5. **Accessible Depth:** Easy to learn core loop, deep mastery through synergy discovery.

---

## 18. Open Design Questions (Future Consideration)

1. **Creature Abilities - Active vs Passive:** Should evolved creatures have activated abilities (cost Energy) or only passive effects?

2. **Multi-Creature Synergies:** How to encourage playing multiple creatures without making single-creature builds unviable?

3. **Enemy Creature Types:** Should enemies have species types that interact with player Traits?

4. **Card Rarity Distribution:** What percentage of rewards should be Common/Uncommon/Rare?

5. **Difficulty Tuning:** How punishing should persistent creature damage be in Act 1 vs Act 3?

---

*Document Version: 2.0*
*Last Updated: December 2024*
