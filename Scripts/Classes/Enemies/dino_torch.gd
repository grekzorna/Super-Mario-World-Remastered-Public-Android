extends Enemy

var dead := false
var can_move := true

func flame_box_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		area.get_parent().damage()

var target_player: Player = null

func spawn() -> void:
	get_tree().physics_frame
	direction = -1

func _physics_process(delta: float) -> void:
	target_player = CoopManager.get_closest_player(global_position)
	if can_move == false:
		velocity.x = 0
	else:
		velocity.x = 50 * direction
	if is_on_wall() and is_on_floor():
		direction_check()
		velocity.y = -250
	velocity.y += 15
	sprite.scale.x = direction
	move_and_slide()

func direction_check() -> void:
	if target_player.global_position.x > global_position.x:
		direction = 1
	elif target_player.global_position.x < global_position.x:
		direction = -1

func flame_attack() -> void:
	target_player = CoopManager.get_closest_player(global_position)
	await get_tree().physics_frame
	can_move = false
	if is_instance_valid(target_player):
		if target_player.global_position.y < global_position.y - 16:
			$Animations.play("FlameUp")
		else:
			$Animations.play("FlameForward")
	else:
		return
	await $Animations.animation_finished
	$Animations.play("Walk")
	can_move = true
	await get_tree().create_timer(2, false).timeout
	$Timer.start()
	

func play_flame_sfx() -> void:
	SoundManager.play_sfx(SoundManager.fire_breath, self)

func damage() -> void:
	can_move = false
	$Hitbox.queue_free()
	$Animations.play("Dead")
	dead = true
