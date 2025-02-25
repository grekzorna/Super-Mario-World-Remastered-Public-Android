extends Node2D

var direction := 1
var speed := 0.0

func _ready() -> void:
	for i in get_parent().get_children():
		if i is OnOffSwitch:
			i.changed.connect(switch)

func _physics_process(delta: float) -> void:
	speed = lerpf(speed, 16 * direction, delta)
	if global_position.y < 0:
		direction = 1
	global_position.y += speed * delta

	global_position.y = clamp(global_position.y, -99999, 160)

func switch() -> void:
	direction *= -1
