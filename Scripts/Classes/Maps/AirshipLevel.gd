extends Node2D

@export var level: LevelInfo = null
@export var hidden_title := "???"
@export var spawn_chance := 5
@export var enter_message: Texture = null
@onready var animation: AnimationPlayer = $AirshipVisual/Animation
@onready var point: MapPoint = get_parent()
@export var level_clear_requirement: LevelInfo = null

static var old_level

var enabled := false
var requirement_true := false

var beaten := false

func _enter_tree() -> void:
	queue_free()

func _ready() -> void:
	GameManager.current_map.level_cleared.connect(check_enter)
	await get_tree().process_frame
	if point.air_ship and not beaten:
		set_enabled()
		animation.play("Loop")

func _process(delta: float) -> void:
	if is_instance_valid(level_clear_requirement):
		requirement_true = SaveManager.is_level_in_array(level_clear_requirement.level_scene_path, SaveManager.current_save.beaten_levels) or SaveManager.is_level_in_array(level_clear_requirement.level_scene_path, SaveManager.current_save.special_beaten_levels)
	else:
		requirement_true = true

func check_enter() -> void:
	if beaten:
		return
	if enabled:
		return
	await get_tree().physics_frame
	if point.air_ship and GameManager.current_map.active_point == point:
		leave()
	elif point.check_if_beaten(SaveManager.current_save.beaten_levels) or point.check_if_beaten(SaveManager.current_save.special_beaten_levels) and requirement_true:
		if randi_range(0, spawn_chance) == 0 and GameManager.current_map.airship_present == false:
			enter()

func enter() -> void:
	GameManager.current_map.airship_queued = true
	await GameManager.current_map.active_point.completed_animation
	if enabled:
		return
	MusicPlayer.map.stop()
	animation.play("Enter")
	GameManager.current_map.can_move = false
	set_enabled()
	await animation.animation_finished
	if enter_message != null:
		SoundManager.play_ui_sound(preload("res://Assets/Audio/SFX/peach-help.wav"))
		await GameManager.show_message(enter_message)
	GameManager.current_map.airship_queued = false
	MusicPlayer.map.play()
	animation.play("Loop")
	GameManager.current_map.can_move = true
	SaveManager.save_current_file()

func leave() -> void:
	if beaten:
		return
	MusicPlayer.map.stop()
	animation.play("Exit")
	GameManager.current_map.can_move = false
	set_disabled()
	await animation.animation_finished
	SoundManager.play_ui_sound(SoundManager.checkpoint)
	MusicPlayer.map.play()
	GameManager.current_map.can_move = true
	SaveManager.save_current_file()

func set_enabled() -> void:
	await get_tree().process_frame
	enabled = true
	GameManager.current_map.airship_present = true
	if SaveManager.current_save.airship_levels.find(point.level.level_scene_path) == -1:
		SaveManager.current_save.airship_levels.append(point.level.level_scene_path)
		SaveManager.current_save.unlocked_levels.append(level.level_scene_path)
	old_level = point.level
	if is_instance_valid(level):
		point.level = level.duplicate()
		point.level.level_title = hidden_title
		point.air_ship = true
	GameManager.current_map.update_info()

func set_disabled() -> void:
	point.air_ship = false
	beaten = true
	GameManager.current_map.airship_present = false
	SaveManager.current_save.airship_beaten_levels.append(old_level.level_scene_path)
	SaveManager.current_save.beaten_levels.append(level.level_scene_path)
	SaveManager.current_save.airship_levels.remove_at(SaveManager.current_save.airship_levels.find(point.level.level_scene_path))
	SaveManager.save_current_file()
	await get_tree().create_timer(0.5).timeout
	enabled = false
	point.level = old_level
	GameManager.current_map.update_info()
