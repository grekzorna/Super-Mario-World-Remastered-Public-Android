extends MapPointVisual

@export_enum("Yellow", "Green", "Blue", "Red") var colour = 0

@onready var normal_sprite: Sprite2D = $Normal
@onready var destroyed_sprite: Sprite2D = $Destroyed

@export var blocks: Texture = null

var can_update := true
const MAP_SWITCH_PALACE_BLOCK_EMITTER = preload("res://Instances/Parts/map_switch_palace_block_emitter.tscn")
func _ready() -> void:
	normal_sprite.frame_coords.y = colour
	destroyed_sprite.frame_coords.y = colour
	destroyed_sprite.frame_coords.x = 1
	map_point.level_cleared.connect(destroy)
	await get_tree().physics_frame
	completed = SaveManager.is_level_in_array(get_parent().level.resource_path, SaveManager.current_save.beaten_levels)
	normal_sprite.visible = not completed
	destroyed_sprite.visible = completed

func destroy() -> void:
	GameManager.can_pause = false
	spawn_particles()
	normal_sprite.show()
	await get_tree().create_timer(0.1, false).timeout
	GameManager.current_map.can_move = false
	GameManager.can_pause = false
	SoundManager.play_sfx("res://Assets/Audio/SFX/map-menu.wav", self)
	await get_tree().create_timer(3, false).timeout
	ParticleManager.summon_particle(ParticleManager.PUFF_SPR, global_position)
	SoundManager.play_sfx(SoundManager.map_castle_destroy, self)
	normal_sprite.hide()
	await get_tree().create_timer(0.25, false).timeout
	destroyed_sprite.show()
	await get_tree().create_timer(0.25, false).timeout
	completed_animation.emit()
	GameManager.current_map.can_move = true
	GameManager.can_pause = true

func spawn_particles() -> void:
	var node = MAP_SWITCH_PALACE_BLOCK_EMITTER.instantiate()
	node.colour = colour
	add_child(node)
