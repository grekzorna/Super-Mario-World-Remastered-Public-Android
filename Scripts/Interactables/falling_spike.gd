extends Node2D

var falling := false

var can_fall := true

var y_vel := 0.0

func _physics_process(delta: float) -> void:
	if falling:
		y_vel += 10
	y_vel = clamp(y_vel, -10, 200)
	global_position.y += y_vel * delta

func _on_player_detect_area_area_entered(area: Area2D) -> void:
	if can_fall == false:
		return
	if area.owner is Player:
		can_fall = false
		shake()

func shake() -> void:
	$Animation.play("Shake")
	await get_tree().create_timer(1, false).timeout
	$Animation.play("RESET")
	falling = true


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		area.owner.damage()
