extends Enemy
const SUMO_BRO_LIGHTNING = preload("res://Instances/Prefabs/Enemies/sumo_bro_lightning.tscn")

func _physics_process(delta: float) -> void:
	velocity.y += 15
	$Sprite.scale.x = -direction
	if ($LeftLedge.is_colliding() == false and direction == -1) or ($RightLedge.is_colliding() == false and direction == 1):
		velocity.x = 0
	move_and_slide()

func stomp() -> void:
	SoundManager.play_sfx(SoundManager.bullet, self)
	GameManager.shake_camera(15)
	summon_lightning()
	await get_tree().create_timer(1, false).timeout
	move()

func summon_lightning() -> void:
	var node = SUMO_BRO_LIGHTNING.instantiate()
	node.global_position = global_position + Vector2(8 * direction, 17)
	add_sibling(node)

func damage() -> void:
	die()

func melee_attack() -> void:
	die()

func move() -> void:
	if $LeftLedge.is_colliding() and $RightLedge.is_colliding():
		direction = [-1, 1].pick_random()
	elif $LeftLedge.is_colliding():
		direction = -1
	elif $RightLedge.is_colliding():
		direction = 1
	velocity.x = 15 * direction
	$Animations.play("Move")
	await get_tree().create_timer(3, false).timeout
	$Animations.play("Stomp")
	velocity.x = 0
