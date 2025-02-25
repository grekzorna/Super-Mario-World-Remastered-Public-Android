extends Node2D

var move := 0.0
const move_speed := 2
@onready var balloon: Node2D = $Balloon

signal grabbed

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	move += move_speed * delta
	global_position.y -= 8 * delta
	global_position.x += 32 * delta
	balloon.position.y = (sin(move) * 8) - 8

func balloon_get(area: Area2D) -> void:
	if area.get_parent() is Player:
		area.get_parent().state_machine.transition_to("PBalloon")
		grabbed.emit()
		queue_free()
