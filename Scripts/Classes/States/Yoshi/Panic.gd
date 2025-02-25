extends YoshiState

var can_hit := true

const move_speed := 100



func enter(_msg := {}) -> void:
	yoshi.yoshi_animations.play("Panic")
	yoshi.yoshi_animations.speed_scale = 5
	yoshi.body.show()

func physics_update(_delta: float) -> void:
	yoshi.velocity.y += 15
	yoshi.velocity.x = move_speed * yoshi.direction
	if yoshi.is_on_wall() and can_hit:
		can_hit = false
		yoshi.direction *= -1
		await get_tree().create_timer(0.1, false).timeout
		can_hit = true
