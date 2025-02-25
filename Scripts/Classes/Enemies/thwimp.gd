extends Enemy

@export var jump_arc: Curve

var moving := false
var move_amount := 0.0
var move_speed := 20
var jump_height := -96
var can_bump := false
@onready var starting_position = global_position

func _ready() -> void:
	direction = -1

func _physics_process(delta: float) -> void:
	if velocity.y < 0:
		velocity.y += 5
	else:
		velocity.y += 15
	if moving:
		velocity.x = 55 * direction
	else:
		velocity.y = clamp(velocity.y, -999, 300)
		if is_on_floor():
			velocity.x = 0
			if can_bump:
				SoundManager.play_sfx(SoundManager.bump, self)
				can_bump = false
	move_and_slide()

func jump() -> void:
	starting_position = global_position
	if not is_on_floor():
		return
	velocity.y = -250
	moving = true
	can_bump = true
	await get_tree().create_timer(1, false).timeout
	direction *= -1
	moving = false
