extends HeldObject
const BODY = preload("res://Assets/Sprites/Enemys/MechaKoopaParts/Body.png")
const FEET = preload("res://Assets/Sprites/Enemys/MechaKoopaParts/Feet.png")
const HEAD = preload("res://Assets/Sprites/Enemys/MechaKoopaParts/Head.png")
const SCREW = preload("res://Assets/Sprites/Enemys/MechaKoopaParts/Screw.png")
var parts := [HEAD, FEET, SCREW, BODY]

func die() -> void:
	ParticleManager.summon_four_part(parts, global_position - Vector2(0, 16), 16)
	SoundManager.play_sfx(SoundManager.shatter, self)
	queue_free()
