extends Node2D

@export_enum("Left", "Up") var direction := "Left"

@onready var animations: AnimationPlayer = $Animations

func _ready() -> void:
	animations.play(direction)
