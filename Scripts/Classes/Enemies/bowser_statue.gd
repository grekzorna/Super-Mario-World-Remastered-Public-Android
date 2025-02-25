extends CharacterBody2D
const BOWSER_STATUE_FLAME = preload("res://Instances/Prefabs/Projectiles/bowser_statue_flame.tscn")
@export var can_fire := true
func _physics_process(delta: float) -> void:
	velocity.y += 15
	move_and_slide()

func spawn_fire() -> void:
	if can_fire == false:
		return
	var node = BOWSER_STATUE_FLAME.instantiate()
	node.global_position = global_position - Vector2(6, 14)
	add_sibling(node)
	SoundManager.play_sfx(SoundManager.boss_flame, self)
