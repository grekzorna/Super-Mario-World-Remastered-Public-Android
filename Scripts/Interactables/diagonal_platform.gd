
extends Node2D

@export_enum("Left", "Right") var direction := "Right"
@onready var animation: AnimationPlayer = $Animation

func _ready() -> void:
	for i in 10:
		print(direction)
		await get_tree().physics_frame
		animation.play(direction)
