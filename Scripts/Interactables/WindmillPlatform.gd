extends Node2D

@export var direction := 1
@onready var spin: Node2D = $Spin

func _ready() -> void:
	if direction == -1:
		$AnimationPlayer.play_backwards("Spin")
