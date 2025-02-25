extends Area2D

var gen_prog := 0.0
const BULLET_BILL = preload("res://Instances/Prefabs/Enemies/bullet_bill.tscn")
func _physics_process(delta: float) -> void:

	if get_overlapping_areas().any(func(area: Area2D): return area.get_parent() is Player):
		gen_prog += 0.5 * delta
	if gen_prog >= 1:
		gen_prog = 0
		spawn_bullet_bill()

func spawn_bullet_bill(position := Vector2.ZERO) -> void:
	var node = BULLET_BILL.instantiate()
	var x = [-1, 1].pick_random()
	node.direction_vector.x = x
	node.global_position = Vector2(get_viewport().get_camera_2d().get_target_position().x, CoopManager.get_first_any_player().global_position.y) + Vector2(-240 * x, -16)
	GameManager.current_level.add_child(node)
