extends PowerUp
 
const move_speed := 50
const jump_height := 300

var can_hit := true
var can_move := false


func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	velocity.y += 15
	velocity.y = clamp(velocity.y, -999, 240)
	if is_on_floor():
		can_move = true
		velocity.y = -jump_height
	if can_move:
		velocity.x = move_speed * direction
	if is_on_wall():
		if can_hit:
			can_hit = false
			direction *= -1
			await get_tree().create_timer(0.25, false).timeout
			can_hit = true
	move_and_slide()


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player and can_grab:
		area.get_parent().super_star()
		queue_free()
