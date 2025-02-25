extends Enemy

const MINI_FLAME = preload("res://Instances/Prefabs/Enemies/mini_flame.tscn")

func _physics_process(delta: float) -> void:
	velocity.y += 5
	sprite.scale.x = -direction
	move_and_slide()
	if is_on_floor():
		velocity.x = lerpf(velocity.x, 0, delta * 20)

func jump() -> void:
	var jump_direction := 1
	var target_player: Player = CoopManager.get_closest_player(global_position)
	if target_player.global_position.x > global_position.x:
		jump_direction = 1
	else:
		jump_direction = -1
	spawn_mini_flame()
	direction = jump_direction
	velocity.y = -100
	await get_tree().physics_frame
	velocity.x = 50 * jump_direction

func spawn_mini_flame() -> void:
	var node = MINI_FLAME.instantiate()
	node.global_position = global_position
	add_sibling(node)
