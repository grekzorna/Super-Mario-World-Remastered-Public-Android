extends Node2D


var speed := 64.0
var can_del := false

const VINE = preload("res://Instances/Prefabs/Interactables/vine.tscn")

var offset := 0

func _ready() -> void:
	SoundManager.play_sfx(SoundManager.vine_grow, self)
	if GameManager.autumn:
		$Sprite.play("autumn")
	offset = int(global_position.x) % 16 == 0

func _physics_process(delta: float) -> void:
	var current_snap := global_position.snapped(Vector2(16, 16))
	global_position.y -= speed * delta
	if $RayCast2D.is_colliding() and can_del:
		queue_free()
		return
	if global_position.snapped(Vector2(16, 16)) != current_snap:
		spawn_vine()
		can_del = true

func spawn_vine() -> void:
	var node = VINE.instantiate()
	node.global_position = global_position.snapped(Vector2(16, 16))
	if not offset:
		node.global_position -= Vector2(8, -8)
	add_sibling(node)
