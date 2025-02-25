extends Node
const GHOST_SHIP_BOO = preload("res://Instances/Prefabs/Enemies/ghost_ship_boo.tscn")

var amount := 100

var boos := []

var can_move := true

var player_in_area := false

func _ready() -> void:
	spawn_boos()
	for i in get_children():
		if i is CollisionShape2D:
			$Area.add_child(i.duplicate())
			i.queue_free()

func _physics_process(delta: float) -> void:
	if can_move:
		$Boos.global_position = get_viewport().get_camera_2d().get_screen_center_position()
		for i in boos:
			i.position = Vector2(randi_range(-240, 240), randi_range(-135, 135)).snapped(Vector2(16, 16))

func spawn_boos() -> void:
	for i in amount:
		var node = GHOST_SHIP_BOO.instantiate()
		boos.append(node)
		$Boos.add_child(node)

func is_player(area: Area2D) -> bool:
	return area.get_parent() is Player

func attack() -> void:
	if player_in_area:
		can_move = false
		for i in boos:
			i.get_node("Animation").play("Appear")
		await get_tree().create_timer(5, false).timeout
		can_move = true
	$Timer.start()


func _on_area_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		player_in_area = true


func _on_area_area_exited(area: Area2D) -> void:
	if area.get_parent() is Player:
		player_in_area = false
