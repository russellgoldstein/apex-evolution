extends Node
## GameManager - Handles scene transitions and global game state

signal state_changed(new_state: Enums.GameState)
signal scene_transition_started
signal scene_transition_completed

var current_state: Enums.GameState = Enums.GameState.MAIN_MENU
var previous_state: Enums.GameState = Enums.GameState.MAIN_MENU

## Scene paths
const SCENES = {
	Enums.GameState.MAIN_MENU: "res://scenes/screens/title_screen.tscn",
	Enums.GameState.ARCHETYPE_SELECT: "res://scenes/screens/archetype_select.tscn",
	Enums.GameState.MAP: "res://scenes/screens/map_screen.tscn",
	Enums.GameState.COMBAT: "res://scenes/screens/combat_screen.tscn",
	Enums.GameState.REWARD: "res://scenes/screens/reward_screen.tscn",
	Enums.GameState.EVOLUTION_SPIRE: "res://scenes/screens/evolution_spire.tscn",
	Enums.GameState.REST_SITE: "res://scenes/screens/rest_site.tscn",
	Enums.GameState.TRAIT_SHRINE: "res://scenes/screens/trait_shrine.tscn",
	Enums.GameState.GAME_OVER: "res://scenes/screens/game_over.tscn",
	Enums.GameState.VICTORY: "res://scenes/screens/victory.tscn",
}

## Reference to main scene (for scene swapping)
var main_scene: Node
var current_screen: Node

## Transition settings
var is_transitioning: bool = false
var transition_duration: float = 0.3

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func set_main_scene(scene: Node) -> void:
	main_scene = scene

func change_state(new_state: Enums.GameState, instant: bool = false) -> void:
	if is_transitioning:
		return

	previous_state = current_state
	current_state = new_state

	if instant:
		_load_scene_for_state(new_state)
	else:
		_transition_to_state(new_state)

	state_changed.emit(new_state)

func _transition_to_state(new_state: Enums.GameState) -> void:
	is_transitioning = true
	scene_transition_started.emit()

	# Fade out
	if main_scene and main_scene.has_method("fade_out"):
		await main_scene.fade_out(transition_duration)
	else:
		await get_tree().create_timer(transition_duration).timeout

	# Load new scene
	_load_scene_for_state(new_state)

	# Fade in
	if main_scene and main_scene.has_method("fade_in"):
		await main_scene.fade_in(transition_duration)
	else:
		await get_tree().create_timer(transition_duration).timeout

	is_transitioning = false
	scene_transition_completed.emit()

func _load_scene_for_state(state: Enums.GameState) -> void:
	if not SCENES.has(state):
		push_error("No scene defined for state: %s" % state)
		return

	var scene_path = SCENES[state]

	# Remove current screen
	if current_screen:
		current_screen.queue_free()
		current_screen = null

	# Load and instance new screen
	var scene = load(scene_path)
	if scene:
		current_screen = scene.instantiate()
		if main_scene:
			main_scene.add_screen(current_screen)
		else:
			get_tree().root.add_child(current_screen)

## Convenience functions for common transitions

func start_new_run() -> void:
	RunData.start_new_run()
	change_state(Enums.GameState.ARCHETYPE_SELECT)

func select_archetype(archetype: ArchetypeData) -> void:
	RunData.initialize_with_archetype(archetype)
	change_state(Enums.GameState.MAP)

func enter_combat(enemies: Array[EnemyData]) -> void:
	RunData.setup_combat(enemies)
	change_state(Enums.GameState.COMBAT)

func combat_victory() -> void:
	change_state(Enums.GameState.REWARD)

func combat_defeat() -> void:
	change_state(Enums.GameState.GAME_OVER)

func return_to_map() -> void:
	change_state(Enums.GameState.MAP)

func enter_evolution_spire() -> void:
	change_state(Enums.GameState.EVOLUTION_SPIRE)

func enter_rest_site() -> void:
	change_state(Enums.GameState.REST_SITE)

func enter_trait_shrine() -> void:
	change_state(Enums.GameState.TRAIT_SHRINE)

func game_over() -> void:
	change_state(Enums.GameState.GAME_OVER)

func victory() -> void:
	change_state(Enums.GameState.VICTORY)

func return_to_main_menu() -> void:
	RunData.clear_run()
	change_state(Enums.GameState.MAIN_MENU)

## Pause handling
var _is_paused: bool = false

func is_paused() -> bool:
	return _is_paused

func pause_game() -> void:
	_is_paused = true
	get_tree().paused = true

func unpause_game() -> void:
	_is_paused = false
	get_tree().paused = false

func toggle_pause() -> void:
	if _is_paused:
		unpause_game()
	else:
		pause_game()
