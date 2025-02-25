extends PowerUp

const move_speed := 50
@onready var hitbox: Area2D = $Area2D

var can_hit := true


func _physics_process(_delta: float) -> void:
	if is_on_floor():
		velocity.x = move_speed * direction
	velocity.y += 15
	velocity.y = clamp(velocity.y, -9999, 275)
	if is_on_wall():
		if can_hit:
			can_hit = false
			direction *= -1
			await get_tree().create_timer(0.1, false).timeout
			can_hit = true
	if hitbox.get_overlapping_areas().any(func(area: Area2D): return area.get_parent() is WaterArea):
		velocity.y = clamp(velocity.y, -9999, 100)
	move_and_slide()
