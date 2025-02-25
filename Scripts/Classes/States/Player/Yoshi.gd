extends PlayerState

@onready var normal: Node = $"../Normal"

func enter(_msg := {}) -> void:
	pass

func update(delta: float) -> void:
	if player.yoshi != null:
		player.global_position = player.yoshi.mario_joint.global_position + Vector2(0, 8)

func physics_update(delta: float) -> void:
	player.current_animation = "YoshiIdle"
	if player.yoshi.is_on_floor():
		player.yoshi.velocity.y = 0
	player.yoshi.velocity = normal.handle_movement(delta)
	if player.yoshi.is_on_floor() and Input.is_action_just_pressed("jump"):
		normal.jump()
