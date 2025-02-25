extends Enemy

var direction_vector := Vector2.RIGHT

const MOVE_SPEED := 100

func _ready() -> void:
	SoundManager.play_sfx(SoundManager.boss_flame, self)

func _physics_process(delta: float) -> void:
	global_position += (MOVE_SPEED * direction_vector) * delta

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		area.owner.damage()
