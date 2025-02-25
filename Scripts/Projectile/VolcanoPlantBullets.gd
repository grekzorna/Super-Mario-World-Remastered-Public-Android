extends Node2D

@onready var bullets = [$Bullet1, $Bullet2, $Bullet3, $Bullet4]

var direction_vectors: Array[Vector2] = [Vector2(-2, -1), Vector2(-1, -2), Vector2(1, -2), Vector2(2, -1)]

var launch_speed := 40
var fall_speed := 35

var falling := false

func _ready() -> void:
	await get_tree().create_timer(1, false).timeout
	falling = true
	await get_tree().create_timer(6, false).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	if falling:
		for i in bullets:
			i.global_position.y += fall_speed * delta
	else:
		var bullet_index := 0
		for i in bullets:
			var vectors = direction_vectors[bullet_index]
			i.global_position += (vectors * launch_speed) * delta
			bullet_index += 1

func bullet_hit(area: Area2D) -> void:
	if area.get_parent() is Player:
		area.get_parent().damage()
