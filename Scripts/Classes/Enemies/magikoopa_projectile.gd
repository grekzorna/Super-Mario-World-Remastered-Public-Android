extends Node2D

var direction := Vector2.RIGHT

func _ready() -> void:
	SoundManager.play_sfx("res://Assets/Audio/SFX/transform.wav", self)

func _physics_process(delta: float) -> void:
	global_position += (128 * direction) * delta


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		area.get_parent().damage()
	elif area.get_parent() is SpinBlock:
		spin_block_hit(area.get_parent())

func spin_block_hit(block: SpinBlock) -> void:
	randomize()
	var rng = randi_range(0, 256)
	if rng < 1:
		summon_block_result(preload("res://Instances/Prefabs/Items/1_up.tscn"), block.global_position)
	elif rng < 8:
		summon_block_result(preload("res://Instances/Prefabs/Items/physics_coin.tscn"), block.global_position)
	elif rng < 9:
		summon_block_result(preload("res://Instances/Prefabs/Enemies/thwimp.tscn"), block.global_position)
	else:
		summon_block_result(preload("res://Instances/Prefabs/Enemies/koopa_troopa.tscn"), block.global_position)
	ParticleManager.summon_particle(ParticleManager.PUFF, block.global_position)
	block.queue_free()
func summon_block_result(scene: PackedScene, spawn_position := Vector2.ZERO) -> void:
	var node = scene.instantiate()
	if node is KoopaTroopa:
		node.colour = 2
	node.global_position = spawn_position + Vector2(0, 8)
	add_sibling(node)
	queue_free()
