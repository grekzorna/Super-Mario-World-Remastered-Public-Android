extends Enemy

@onready var starting_position = global_position

var can_swoop := true

var swooping := false

var move := 0.0

const SWOOP_HEIGHT := 96

const SWOOP_SPEED := 1

const HORI_SPEED := 100

func _physics_process(delta: float) -> void:
	move += SWOOP_SPEED * delta
	global_position.y = starting_position.y + sin(move) * SWOOP_HEIGHT
	global_position.x += (HORI_SPEED * direction) * delta
	sprite.scale.x = -direction

func damage() -> void:
	die()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	$Sprite/AnimationPlayer.play("Fly")
	if CoopManager.get_closest_player(global_position).global_position.x > global_position.x:
		direction = 1
	else:
		direction = -1
