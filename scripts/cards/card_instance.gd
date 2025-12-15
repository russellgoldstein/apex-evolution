class_name CardInstance
extends RefCounted
## Runtime instance of a card in the player's deck

# Preload to ensure class is available
const CreatureInstanceScript = preload("res://scripts/combat/creature_instance.gd")
const CreatureCardDataScript = preload("res://scripts/resources/creature_card_data.gd")
const ActionCardDataScript = preload("res://scripts/resources/action_card_data.gd")

var data: CardData  ## The card data (CreatureCardData or ActionCardData)
var instance_id: int

## For creature cards, link to the creature instance
var creature_instance

## Card state
var is_upgraded: bool = false
var upgraded_data: CardData  ## If upgraded, this holds the upgraded version

static var _next_id: int = 0

func _init(card_data: CardData) -> void:
	data = card_data
	instance_id = _next_id
	_next_id += 1

func get_data() -> CardData:
	## Returns upgraded data if upgraded, otherwise base data
	if is_upgraded and upgraded_data:
		return upgraded_data
	return data

func get_energy_cost() -> int:
	return get_data().energy_cost

func get_name() -> String:
	var card = get_data()
	if is_upgraded and not card.card_name.ends_with("+"):
		return card.card_name + "+"
	return card.card_name

func is_creature_card() -> bool:
	return data is CreatureCardData

func is_action_card() -> bool:
	return data is ActionCardData

func get_creature_data() -> CreatureCardData:
	if is_creature_card():
		return get_data() as CreatureCardData
	return null

func get_action_data() -> ActionCardData:
	if is_action_card():
		return get_data() as ActionCardData
	return null

func can_be_played(energy: int, has_creatures: bool) -> bool:
	## Check if this card can be played given current state
	if get_energy_cost() > energy:
		return false

	if is_action_card():
		var action = get_action_data()
		if action.requires_creature and not has_creatures:
			return false

	return true

func has_keyword(keyword: Enums.CardKeyword) -> bool:
	return get_data().has_keyword(keyword)

func upgrade() -> bool:
	## Attempt to upgrade this card
	if is_upgraded:
		return false

	if is_action_card():
		var action = get_action_data()
		if action.upgraded_version:
			upgraded_data = action.upgraded_version
			is_upgraded = true
			return true

	# For creature cards, upgrading gives +1 ATK or +2 HP
	# This is handled separately through evolution

	return false

func duplicate_instance() -> CardInstance:
	## Create a copy of this card instance
	var copy = CardInstance.new(data)
	copy.is_upgraded = is_upgraded
	copy.upgraded_data = upgraded_data
	if creature_instance:
		copy.creature_instance = creature_instance
	return copy
