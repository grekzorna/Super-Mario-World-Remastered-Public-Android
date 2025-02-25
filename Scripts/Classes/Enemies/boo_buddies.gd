extends Node2D

@onready var boos = $Boos.get_children()
@onready var rotation_joint: Node2D = $RotationJoint

const length := 80

var player: Player = null

func _ready() -> void:
	for i in boos:
		i.play(str(randi_range(1, 3)))

func _physics_process(delta: float) -> void:
	var boo_index := 0
	player = CoopManager.get_closest_player(global_position)
	for i in boos:
		i.global_position = global_position + Vector2.from_angle(deg_to_rad(rotation_joint.global_rotation_degrees + (30 * boo_index))).normalized() * length
		if player != null:
			i.flip_h = i.global_position.x > player.global_position.x
		boo_index += 1


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		area.get_parent().damage()
