extends HeldObject

@onready var flash_animation: AnimationPlayer = $FlashAnimation
const EXPLOSION = preload("res://Instances/Prefabs/Interactables/explosion.tscn")
var fuse := 5.0

func physics_update(delta: float) -> void:
	fuse -= 1 * delta
	if fuse <= 2:
		flash_animation.play("Flash")
	if fuse <= 0:
		summon_explosion()

func summon_explosion() -> void:
	var node = EXPLOSION.instantiate()
	node.global_position = global_position
	GameManager.current_level.add_child(node)
	queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Fireball:
		direction = area.get_parent().direction
		kick_forward()
