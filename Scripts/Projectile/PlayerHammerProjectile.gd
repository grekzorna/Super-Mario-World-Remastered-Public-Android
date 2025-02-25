class_name HammerProjectile
extends CharacterBody2D

const launch_speed = Vector2(150, -300)
var direction := 1

func _ready() -> void:
	velocity = launch_speed
	velocity.x = launch_speed.x * direction

func _physics_process(delta: float) -> void:
	velocity.y += 15
	if is_on_floor():
		queue_free()
	if is_on_wall():
		queue_free()
	if is_on_ceiling():
		queue_free()
	move_and_slide()
