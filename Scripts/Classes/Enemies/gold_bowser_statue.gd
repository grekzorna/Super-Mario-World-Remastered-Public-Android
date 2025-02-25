extends Enemy

@export var can_fire := true
func _physics_process(delta: float) -> void:
	velocity.y += 15
	if is_on_floor():
		$Sprite.play("Idle")
		velocity.x = 0
	else: 
		velocity.x = 100 * direction
		$Sprite.play("Jump")
	sprite.scale.x = -direction
	move_and_slide()

func jump() -> void:
	var player: Player = CoopManager.get_closest_player(global_position)
	if global_position.x > player.global_position.x:
		direction = -1
	else:
		direction = 1
	velocity.y = -350
