extends Node2D

var flip_blue := false
@onready var platform: StaticBody2D = $Platform
@onready var animation_player: AnimationPlayer = $Platform/AnimationPlayer

@export_enum("Red", "Blue") var starting_colour := "Red"

func _ready() -> void:
	flip_blue = starting_colour == "Blue"
	platform.rotation_degrees = (180 if flip_blue else 0)
	GameManager.player.on_jump.connect(flip_platform)

func flip_platform() -> void:
	if flip_blue:
		animation_player.play("Flip1")
	else:
		animation_player.play("Flip2")
	
	flip_blue = !flip_blue
