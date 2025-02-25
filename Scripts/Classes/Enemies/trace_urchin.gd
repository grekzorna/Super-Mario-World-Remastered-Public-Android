extends Enemy

@export var move_speed := 100

var direction_vector := Vector2.ZERO
@export var movement_direction := 1
var can_corner := false

func _ready() -> void:
	global_position.y += 2
	direction_vector = Vector2(movement_direction, 0)

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(direction_vector.rotated(deg_to_rad(90 * movement_direction)) * 2, false, 1)
	if is_instance_valid(collision):
		can_corner = true
		collision = move_and_collide(direction_vector, false, 1)
		if is_instance_valid(collision):
			turn(-90 * movement_direction)
	elif can_corner:
		can_corner = false
		turn(90 * movement_direction)
	move(delta)

func move(delta: float) -> void:
	global_position += (move_speed * direction_vector) * delta

func turn(turn_angle: float) -> void:
	direction_vector = direction_vector.rotated(deg_to_rad(turn_angle))
