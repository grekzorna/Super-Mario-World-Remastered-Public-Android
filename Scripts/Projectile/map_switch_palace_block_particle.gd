extends CharacterBody2D

@export var direction_vector := Vector2.DOWN
var launch_speed := 200

@export_enum("Yellow", "Green", "Blue", "Red") var colour := 0

const gravity := 10

var can_move := false

func _ready() -> void:
	velocity = launch_speed * direction_vector
	velocity.y -= 300
	can_move = true

func _physics_process(delta: float) -> void:
	$Sprite.frame = colour
	if can_move:
		velocity.y += gravity
		move_and_slide()
