@icon("res://Assets/Sprites/Editor/Icons/Pipe.png")
class_name Pipe
extends Node

@export_enum("Down", "Up", "Left", "Right") var enter_direction := "Down"
@export_file("*.tscn") var level_scene := ""
@export var pipe_id := 0
@export var auto_exit := false
@onready var sprite: Sprite2D = $Sprite
@export var exit_only := false
@export var cannon_exit := false
@onready var input_direction = get_input_direction()

var can_enter := true

signal used
@onready var hitbox: Area2D = $Hitbox

var player: Player = null

var pipe_used := false

var enter_vector := Vector2.DOWN

signal player_left_area

func _ready() -> void:
	GameManager.current_level.pipes[pipe_id] = self
	used.connect(on_use)
	sprite.hide()
	if auto_exit and not CoopManager.pipe_exiting:
		if GameManager.checkpoint_level != GameManager.current_level.scene_file_path:
			CoopManager.handle_pipe_exits(pipe_id, enter_direction)

func get_enter_vector() -> Vector2:
	match enter_direction:
		"Up":
			return Vector2.UP
		"Down":
			return Vector2.DOWN
		"Left":
			return Vector2.LEFT
		"Right":
			return Vector2.RIGHT
		_:
			return Vector2.ZERO

func _process(_delta: float) -> void:
	if pipe_used == false and exit_only == false and can_enter:
		for i in hitbox.get_overlapping_areas():
			if i.get_parent() is Player:
				player = i.get_parent()
				if enter_direction == "Left" or enter_direction == "Right":
					if player.is_on_floor() == false:
						return
				if Input.is_action_pressed(CoopManager.get_player_input_str(input_direction, player.player_id)):
					enter()

func enter() -> void:
	if pipe_used:
		return
	pipe_used = true
	used.emit()
	player.enter_pipe(enter_direction, self)
	await get_tree().create_timer(0.5).timeout
	if level_scene != "":
		TransitionManager.pipe_transition_to_level(level_scene, GameManager.current_level, pipe_id)

func get_input_direction() -> String:
	match enter_direction:
		"Down":
			return "move_down"
		"Up":
			return "move_up"
		"Left":
			return "move_left"
		"Right":
			return "move_right"
		_:
			return "Down"

func get_id() -> int:
	return pipe_id


func on_use() -> void:
	can_enter = false
	await get_tree().create_timer(0.5, false).timeout
	can_enter = true

func _on_hitbox_area_exited(area: Area2D) -> void:
	if area.get_parent() is Player:
		player_left_area.emit()
