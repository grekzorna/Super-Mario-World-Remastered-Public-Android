extends Enemy

@export_enum("Green", "Red") var colour := "Green"
@export_enum("Front", "Back") var starting_face := "Front"
@export_enum("Horizontal", "Vertical") var movement_direction := 0

@onready var hitbox: Area2D = $Hitbox

var can_turn := false

var turning := false

var speed := 0
var can_hit := true

@onready var current_face = starting_face

const FAST_SPEED := 75
const SLOW_SPEED := 50

var movement_vector := Vector2.ZERO

func _ready() -> void:
	match movement_direction:
		0:
			movement_vector = Vector2.LEFT
		1:
			movement_vector = Vector2.UP
	if colour == "Green":
		speed = SLOW_SPEED
	else:
		speed = FAST_SPEED
		
	velocity = movement_vector * (speed * direction)
	for i in 4:
		await get_tree().physics_frame
	can_turn = true

func _physics_process(delta: float) -> void:
	if hitbox.get_overlapping_areas().any(is_climbable) == false and can_turn:
		can_turn = false
		turn()
	if (is_on_floor() or is_on_wall() or is_on_ceiling()) and can_hit:
		bounce()
		await get_tree().create_timer(0.5, false).timeout
		can_hit = true
	if sprite.animation != update_sprite():
		sprite.play(update_sprite())
	move_and_slide()

func bounce() -> void:
	can_hit = false
	direction *= -1
	velocity = movement_vector * (speed * direction)

func damage() -> void:
	die()

func damage_player(player: Player) -> void:
	if z_index == player.z_index:
		player.damage()


func turn() -> void:
	if turning:
		return
	turning = true
	velocity = Vector2.ZERO
	await get_tree().create_timer(0.2, false).timeout
	direction *= -1
	if current_face == "Back":
		current_face = "Front"
	else:
		current_face = "Back"
	velocity = (movement_vector * speed) * direction
	turning = false
	await get_tree().create_timer(0.2, false).timeout
	can_turn = true

func is_climbable(area: Area2D) -> bool:
	return area is Climbable

func update_sprite() -> String:
	var animation := ""
	sprite.scale.x = -direction
	if turning:
		z_index = 0
		return colour + "Turn"
	else:
		if current_face == "Back":
			z_index = 0
		else:
			z_index = -3
		return colour + "Climb" + current_face
