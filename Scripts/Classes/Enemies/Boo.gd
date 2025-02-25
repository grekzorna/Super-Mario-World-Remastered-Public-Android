extends Enemy

var hiding := false

@export var move_speed := 50
var direction_vector := Vector2.ZERO

var wave := 0.0
var turning := false
func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var player = CoopManager.get_closest_player(global_position)
	if player.global_position.x > global_position.x:
		direction = 1
	else:
		direction = -1
	wave += 16 * delta
	hiding = player.direction != direction
	direction_vector = (global_position.direction_to(player.global_position + Vector2(0, sin(wave) * 4)))
	
	if hiding:
		velocity = lerp(velocity, Vector2.ZERO, delta * 10)
	else:
		velocity = lerp(velocity, move_speed * direction_vector, delta)
	if sprite.scale.x != direction and not turning:
		turning = true
		sprite.play("Turn")
		await get_tree().create_timer(0.5, false).timeout
		sprite.scale.x = direction
		await get_tree().create_timer(0.5, false).timeout
		turning = false
	if not turning:
		if hiding:
			sprite.play("Hide")
		else:
			sprite.play("Chase")
	move_and_slide()
