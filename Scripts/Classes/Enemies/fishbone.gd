extends Enemy

var parts := [preload("res://Assets/Sprites/Enemys/FishBoneParts/Body.png"), preload("res://Assets/Sprites/Enemys/FishBoneParts/Head.png"), preload("res://Assets/Sprites/Enemys/FishBoneParts/Tail.png"), null]

var vel_x := 0.0

var wave := 0.0

func _physics_process(delta: float) -> void:
	wave += 4 * delta
	vel_x = (sin(wave) * 16) + 32
	global_position.x -= vel_x * delta


func die(add_score := false) -> void:
	summon_gib()
	SoundManager.play_sfx(SoundManager.bone_crumble, self)
	SoundManager.play_sfx(SoundManager.bump, self)
	SoundManager.play_sfx(SoundManager.shatter, self)
	queue_free()

func summon_gib() -> void:
	ParticleManager.summon_four_part(parts, global_position)
