extends StaticBody2D

@export var entity: PackedScene = null
const BLOCK_BREAK = preload("res://Assets/Sprites/Particles/BlockBreak.png")
func _ready() -> void:
	pass

func summon_entity() -> void:
	var node = entity.instantiate()
	node.global_position = global_position
	if node is KoopaTroopa or node is ShelllessKoopa:
		node.colour = 1
	if node is CharacterBody2D:
		node.velocity.y = -200
	ParticleManager.summon_four_part([BLOCK_BREAK, BLOCK_BREAK, BLOCK_BREAK, BLOCK_BREAK], global_position, 8)
	SoundManager.play_sfx(SoundManager.shatter, self)
	GameManager.current_level.add_child(node)
	queue_free()

func _physics_process(delta: float) -> void:
	if $PlayerDetectArea.get_overlapping_areas().any(func(area): return area.owner is Player):
		summon_entity()
