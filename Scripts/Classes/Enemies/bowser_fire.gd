extends Enemy

@onready var starting_position := global_position

var wave := 0.0

var timer := 3.0

func _ready() -> void:
	await get_tree().process_frame
	wave = randf_range(0, 2*PI)
	SoundManager.play_sfx(SoundManager.boss_flame, self)

func _physics_process(delta: float) -> void:
	velocity.y = 100
	wave += 48 * delta
	if not is_on_floor():
		global_position.x = starting_position.x + sin(wave) * 2
	else:
		timer -= 1 * delta
		if timer <= 0:
			ParticleManager.summon_particle(ParticleManager.PUFF_SPR, global_position)
			queue_free()
	move_and_slide()
