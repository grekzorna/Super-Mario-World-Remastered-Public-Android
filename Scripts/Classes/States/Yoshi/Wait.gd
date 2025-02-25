extends YoshiState

func enter(_msg := {}) -> void:
	yoshi.body.show()

func update(_delta: float) -> void:
	yoshi.yoshi_animations.play("Wait")

func physics_update(delta: float) -> void:
	if yoshi.is_on_floor():
		yoshi.velocity.y = -100
		yoshi.velocity.x = lerpf(yoshi.velocity.x, 0, delta * 50)
	yoshi.velocity.y += 15
	
