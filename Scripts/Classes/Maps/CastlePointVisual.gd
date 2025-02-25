extends MapPointVisual

@onready var normal_sprite: Sprite2D = $Normal
@onready var destroyed_sprite: Sprite2D = $Destroyed

var can_update := true

func _ready() -> void:
	map_point.level_cleared.connect(destroy)
	for i in 2:
		await get_tree().physics_frame
	completed = SaveManager.is_level_in_array(map_point.level.resource_path, SaveManager.current_save.beaten_levels)
	normal_sprite.visible = not completed
	destroyed_sprite.visible = completed
	
	if SaveManager.current_save.game_beaten and completed:
		normal_sprite.show()
		normal_sprite.frame = 1
		destroyed_sprite.hide()

func destroy() -> void:
	SoundManager.play_sfx(SoundManager.map_castle_destroy, self)
	ParticleManager.summon_particle(ParticleManager.PUFF_SPR, self.global_position)
	normal_sprite.hide()
	destroyed_sprite.show()
	await get_tree().create_timer(0.25, false).timeout
	completed_animation.emit()
