class_name PipeToPipeArea
extends Node2D

@export_enum("Up", "Down", "Left", "Right") var entering_direction := "Down"
@export var connecting_pipe: PipeToPipeArea = null
@export var path: Curve2D = null
@export var travel_speed := 200
@export var reverse_path := false
@export var exit_only := false
@export var cannon_exit := false
var pipe_used := false
signal used

@onready var enter_input := get_enter_input()

@onready var hitbox: Area2D = $Hitbox

func _ready() -> void:
	$Sprite.hide()

func _physics_process(delta: float) -> void:
	if exit_only:
		return
	for i in hitbox.get_overlapping_areas():
		if i.get_parent() is Player:
			var player: Player = i.get_parent()
			if player.state_machine.state.name.contains("Pipe"):
				return
			if Input.is_action_pressed(CoopManager.get_player_input_str(enter_input, player.player_id)):
				if entering_direction == "Left" or entering_direction == "Right":
					if player.is_on_floor() == false:
						return
				player.enter_pipe(entering_direction, self)
				player.pipe_travel_speed = travel_speed
				player.pipe_travel_path = path
				player.pipe_travel_destination = connecting_pipe
				player.pipe_travel_reverse = reverse_path
				await get_tree().create_timer(0.5, false).timeout
				player.state_machine.transition_to("PipeTravel")

func get_enter_input() -> String:
	var input := ""
	match entering_direction:
		"Up":
			input = "move_up"
		"Down":
			input = "move_down"
		"Left":
			input = "move_left"
		"Right":
			input = "move_right"
	return input
