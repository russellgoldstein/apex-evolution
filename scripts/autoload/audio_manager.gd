extends Node
## AudioManager - Handles all game audio

## Audio buses
const MASTER_BUS = "Master"
const MUSIC_BUS = "Music"
const SFX_BUS = "SFX"

## Volume settings (0.0 to 1.0)
var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 1.0

## Audio players
var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS = 8

## Current music track
var current_music: AudioStream

## Fade settings
var is_fading: bool = false
var fade_tween: Tween

func _ready() -> void:
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = MUSIC_BUS
	add_child(music_player)

	# Create SFX player pool
	for i in range(MAX_SFX_PLAYERS):
		var player = AudioStreamPlayer.new()
		player.bus = SFX_BUS
		add_child(player)
		sfx_players.append(player)

	# Apply initial volumes
	_apply_volumes()

func _apply_volumes() -> void:
	# Note: In a full implementation, you'd set the bus volumes here
	# AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MASTER_BUS), linear_to_db(master_volume))
	pass

## Music functions

func play_music(stream: AudioStream, fade_in: bool = true) -> void:
	if stream == current_music and music_player.playing:
		return

	if fade_in and music_player.playing:
		await fade_out_music(0.5)

	current_music = stream
	music_player.stream = stream
	music_player.volume_db = linear_to_db(music_volume) if not fade_in else -80.0
	music_player.play()

	if fade_in:
		fade_in_music(0.5)

func stop_music(fade_out: bool = true) -> void:
	if fade_out:
		await fade_out_music(0.5)
	music_player.stop()
	current_music = null

func fade_in_music(duration: float) -> void:
	if fade_tween:
		fade_tween.kill()

	fade_tween = create_tween()
	fade_tween.tween_property(music_player, "volume_db", linear_to_db(music_volume), duration)

func fade_out_music(duration: float) -> void:
	if fade_tween:
		fade_tween.kill()

	is_fading = true
	fade_tween = create_tween()
	fade_tween.tween_property(music_player, "volume_db", -80.0, duration)
	await fade_tween.finished
	is_fading = false

## SFX functions

func play_sfx(stream: AudioStream, volume_scale: float = 1.0) -> void:
	if not stream:
		return

	# Find available player
	var player = _get_available_sfx_player()
	if player:
		player.stream = stream
		player.volume_db = linear_to_db(sfx_volume * volume_scale)
		player.play()

func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player

	# If all are busy, use the first one (interrupt oldest sound)
	return sfx_players[0]

## Common sound effect shortcuts (to be populated with actual sounds)

func play_card_draw() -> void:
	# play_sfx(preload("res://assets/audio/sfx/card_draw.wav"))
	pass

func play_card_play() -> void:
	# play_sfx(preload("res://assets/audio/sfx/card_play.wav"))
	pass

func play_attack() -> void:
	# play_sfx(preload("res://assets/audio/sfx/attack.wav"))
	pass

func play_damage() -> void:
	# play_sfx(preload("res://assets/audio/sfx/damage.wav"))
	pass

func play_heal() -> void:
	# play_sfx(preload("res://assets/audio/sfx/heal.wav"))
	pass

func play_shield() -> void:
	# play_sfx(preload("res://assets/audio/sfx/shield.wav"))
	pass

func play_creature_death() -> void:
	# play_sfx(preload("res://assets/audio/sfx/creature_death.wav"))
	pass

func play_enemy_death() -> void:
	# play_sfx(preload("res://assets/audio/sfx/enemy_death.wav"))
	pass

func play_button_click() -> void:
	# play_sfx(preload("res://assets/audio/sfx/button_click.wav"))
	pass

func play_victory() -> void:
	# play_sfx(preload("res://assets/audio/sfx/victory.wav"))
	pass

func play_defeat() -> void:
	# play_sfx(preload("res://assets/audio/sfx/defeat.wav"))
	pass

func play_evolution() -> void:
	# play_sfx(preload("res://assets/audio/sfx/evolution.wav"))
	pass

func play_trait_acquired() -> void:
	# play_sfx(preload("res://assets/audio/sfx/trait_acquired.wav"))
	pass

## Volume controls

func set_master_volume(volume: float) -> void:
	master_volume = clampf(volume, 0.0, 1.0)
	_apply_volumes()

func set_music_volume(volume: float) -> void:
	music_volume = clampf(volume, 0.0, 1.0)
	music_player.volume_db = linear_to_db(music_volume)

func set_sfx_volume(volume: float) -> void:
	sfx_volume = clampf(volume, 0.0, 1.0)
