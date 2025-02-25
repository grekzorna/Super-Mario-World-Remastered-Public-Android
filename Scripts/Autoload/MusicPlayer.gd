extends Node

@onready var game: AudioStreamPlayer = $Game
@onready var close: AudioStreamPlayer = $Close
@onready var music_override: AudioStreamPlayer = $MusicOverride
@onready var map: AudioStreamPlayer = $Map

const FORTRESS_CLEAR = preload("res://Assets/Audio/BGM/SMW/BossDefeated.mp3")
const LEVEL_CLEAR = preload("res://Assets/Audio/BGM/SMW/LevelClear.mp3")
const P_SWITCH = preload("res://Assets/Audio/BGM/SMW/PSwitch.mp3")
const INVINCIBLE = preload("res://Assets/Audio/BGM/SMW/Starman.mp3")
const SECRET_EXIT = preload("res://Assets/Audio/BGM/SMW/SecretExit.mp3")
const PLAYER_DEAD = preload("res://Assets/Audio/BGM/SMW/PlayerDie.mp3")#Music Library

var is_yoshi := false
var is_hurry := false

var current_music_override_priority := 0

var music_override_persistent := false

var current_game_track: AudioStream = null

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	is_yoshi = CoopManager.active_players.values().any(func(player): if is_instance_valid(player): return player.riding_yoshi)
	is_hurry = GameManager.time < 100
	if TransitionManager.loading_scene or TransitionManager.changing_scene:
		return
	if is_instance_valid(GameManager.current_level):
		handle_level_music()
	else:
		game.stop()
	if is_instance_valid(GameManager.current_map) == false:
		map.stop()
	elif is_instance_valid(GameManager.current_map_area):
		handle_map_music()


func handle_map_music() -> void:
	var track: AudioStream = GameManager.current_map_area.music
	if GameManager.autumn and SettingsManager.settings_file.autumn_type == 0:
		if is_instance_valid(GameManager.current_map_area.autumn_music):
			track = GameManager.current_map_area.autumn_music
	if map.stream != track and track != null:
		map.stop()
		map.stream = track
		map.play()
		if track.has_meta("Name"):
			update_song_label(track.get_meta("Name"), track.get_meta("Artist"))
	elif track == null:
		map.stop()

func handle_level_music() -> void:
	var track: AudioStreamInteractive = GameManager.current_level.level_music
	if GameManager.autumn and SettingsManager.settings_file.autumn_type == 0:
		if is_instance_valid(GameManager.current_level.autumn_music):
			track = GameManager.current_level.autumn_music
	if game.stream != track:
		game.stop()
		game.stream = track
		if track != null:
			if track.has_meta("Name"):
				update_song_label(track.get_meta("Name"), track.get_meta("Artist"))
	var track_name := "Normal"
	
	var track_names := ["Normal", "Yoshi", "Hurry", "HurryYoshi"]
	
	if is_hurry:
		if is_yoshi:
			track_name = "HurryYoshi"
		else:
			track_name = "Hurry"
	elif is_yoshi:
		track_name = "Yoshi"
	if game.get("parameters/switch_to_clip") != track_name:
		game.set("parameters/switch_to_clip", track_name)
	
	if music_override.stream == null and game.playing == false:
		await get_tree().physics_frame
		game.play()


func stop_level_music() -> void:
	game.stop()
	music_override.stop()

func update_song_label(track_name := "", track_artist := "") -> void:
	$MusicNotif/Control/PanelContainer/Label.text = "   " + track_name + " - " + track_artist
	$MusicNotif/Control/Animation.play("Enter")

func set_music_override(stream: AudioStream, priority := 0, persistent := false) -> void:
	if priority < current_music_override_priority:
		return
	current_music_override_priority = priority
	music_override_persistent = persistent
	music_override.stream = stream
	game.stop()
	music_override.play()

func stop_music_override(stream, force := false) -> void:
	if stream != music_override.stream and force != true:
		return
	music_override.stop()
	music_override.stream = null
	current_music_override_priority = 0
	if music_override.playing:
		game.play()

func p_switch() -> void:
	set_music_override(P_SWITCH, 1)
	await GameManager.current_level.p_switch_ended
	stop_music_override(P_SWITCH)

func super_star() -> void:
	set_music_override(INVINCIBLE, 1)
	await GameManager.star_ended
	stop_music_override(INVINCIBLE)

func play_course_clear_fanfare() -> void:
	var theme = LEVEL_CLEAR
	if GameManager.current_level.custom_victory_theme != null:
		theme = GameManager.current_level.custom_victory_theme
	set_music_override(theme, 5)

func play_boss_defeated_theme() -> void:
	set_music_override(FORTRESS_CLEAR, 5)
