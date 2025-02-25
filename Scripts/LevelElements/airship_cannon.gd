extends StaticBody2D
@onready var holder: Sprite2D = $Holder
@onready var timer: Timer = $Timer

@export var holder_rotation := 0
@export var ball_time := 3.0

const CANNON_BALL = preload("res://Instances/Prefabs/Projectiles/cannon_ball.tscn")
func _ready() -> void:
	holder.global_rotation_degrees = holder_rotation
	holder.z_index = z_index
	timer.start(ball_time)

func _process(delta: float) -> void:
	holder.global_position = global_position
	holder.show()

func summon_cannon_ball() -> void:
	var node = CANNON_BALL.instantiate()
	node.direction_vector = Vector2.UP.rotated(global_rotation)
	node.global_position = global_position + (node.direction_vector * 8)
	GameManager.current_level.add_child(node)
