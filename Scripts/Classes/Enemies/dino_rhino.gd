extends Enemy

var target_player: Player = null
const DINO_TORCH_SCENE = preload("res://Instances/Prefabs/Enemies/dino_torch.tscn")
func _physics_process(delta: float) -> void:
	target_player = CoopManager.get_closest_player(global_position)
	velocity.x = 50 * direction
	if is_on_wall() and is_on_floor():
		velocity.y = -200
	velocity.y += 15
	sprite.scale.x = direction
	move_and_slide()

func damage() -> void:
	summon_small_dino()
	queue_free()

func summon_small_dino() -> void:
	var node = DINO_TORCH_SCENE.instantiate()
	node.global_position = global_position
	add_sibling(node)
	node.flame_attack()

func direction_check() -> void:
	if target_player.global_position.x > global_position.x:
		direction = 1
	else:
		direction = -1
