extends Control
## Main scene - handles screen management and transitions

@onready var screen_container: Control = $ScreenContainer
@onready var fade_overlay: ColorRect = $FadeOverlay

var fade_tween: Tween

func _ready() -> void:
	# Register with GameManager
	GameManager.set_main_scene(self)

	# Start with overlay hidden
	fade_overlay.color = Color(0, 0, 0, 0)

	# Load title screen
	GameManager.change_state(Enums.GameState.MAIN_MENU, true)

func add_screen(screen: Node) -> void:
	screen_container.add_child(screen)

func fade_out(duration: float) -> void:
	if fade_tween:
		fade_tween.kill()

	fade_tween = create_tween()
	fade_tween.tween_property(fade_overlay, "color:a", 1.0, duration)
	await fade_tween.finished

func fade_in(duration: float) -> void:
	if fade_tween:
		fade_tween.kill()

	fade_tween = create_tween()
	fade_tween.tween_property(fade_overlay, "color:a", 0.0, duration)
	await fade_tween.finished
