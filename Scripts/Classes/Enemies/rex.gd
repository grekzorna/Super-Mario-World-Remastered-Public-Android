extends Enemy

const move_speed := 30.0
const small_move_speed := 60

var can_hit := true
@onready var normal_collision: CollisionShape2D = $NormalCollision

var can_move := true
var is_small := false

var dead := false

func _physics_process(delta: float) -> void:
	sprite.scale.x = -direction
	if can_move:
		if is_small:
			velocity.x = small_move_speed * direction
		else:
			velocity.x = move_speed * direction
	else:
		velocity.x = 0
	velocity.y += 15
	if is_on_wall() && can_hit:
		can_hit = false
		direction *= -1
		await get_tree().create_timer(0.1, false).timeout
		can_hit = true
	move_and_slide()

func damage() -> void:
	if not is_small:
		ice_size.y = 1
		$NormalCollision.queue_free()
		$NormalHitbox.queue_free()
		$SmallHitbox.set_deferred("monitorable", true)
		can_move = false
		is_small = true
		enemy_height = 8
		sprite.play("Transition")
		await get_tree().create_timer(0.5).timeout
		if not dead:
			can_move = true
			sprite.play("Small")
	else:
		$SmallHitbox.queue_free()
		dead = true
		sprite.play("Die")
		can_move = false
		await get_tree().create_timer(0.35).timeout
		queue_free()
