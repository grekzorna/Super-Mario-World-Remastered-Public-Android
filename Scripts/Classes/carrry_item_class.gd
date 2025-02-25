class_name CarryItem
extends CharacterBody2D

@export var ground_friction := 10
@onready var collision: CollisionShape2D = $Collision

var carried := false
var direction := 1
var can_hurt := false
var can_fall = true

var thrown := false
var moving := false

@export var destructable := false

var velocity_lerp := Vector2.ZERO

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	collision.set_deferred("disabled", carried)
	if can_fall:
		velocity.y += 15
	velocity_lerp = lerp(velocity_lerp, velocity, delta * 20)
	moving = abs(velocity_lerp.x) > 10
	can_hurt = abs(velocity.x) > 100
	if is_on_wall() and destructable:
		if abs(velocity_lerp.x) > 100:
			destroy()
	if is_on_floor():
		velocity.x = lerpf(velocity.x, 0, delta * ground_friction)
	move_and_slide()
	physics_update(delta)

func physics_update(delta: float) -> void:
	pass

func throw() -> void:
	velocity.x = 200 * direction
	carried = false
	thrown = true
	can_fall = true

func destroy() -> void:
	queue_free()
