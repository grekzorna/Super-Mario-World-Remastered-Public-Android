extends Enemy

@export var move_speed := 100

var direction_vector := Vector2.ZERO
@export var movement_direction := 1
@export var can_rotate := false
var can_corner := false
var current_rotation := 0.0

@export var visual_rotation_offset := Vector2.ONE

func _ready() -> void:
	global_position.y += 2
	direction_vector = Vector2(movement_direction, 0)

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(direction_vector.rotated(deg_to_rad(90 * movement_direction)), false, 1)
	up_direction = -Vector2.UP.rotated(direction_vector.angle())
	if is_on_wall():
		turn(-90 * movement_direction)
	if is_instance_valid(collision):
		can_corner = true
	elif can_corner:
		can_corner = false
		turn(90 * movement_direction)
	if can_rotate:
		var target_rotation = (direction_vector * (visual_rotation_offset * Vector2(movement_direction, 1))).angle()
		current_rotation = lerp_angle(current_rotation, target_rotation, delta * 10)
		sprite.rotation = snappedf(current_rotation, deg_to_rad(45))
	velocity = direction_vector * move_speed
	move_and_slide()


func turn(turn_angle: float) -> void:
	direction_vector = direction_vector.rotated(deg_to_rad(turn_angle))
