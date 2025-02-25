extends Enemy

func _ready() -> void:
	SoundManager.play_sfx(SoundManager.boss_flame, self)

func _physics_process(delta: float) -> void:
	global_position.x -= 64 * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_visible_on_screen_enabler_2d_screen_entered() -> void:
	SoundManager.play_sfx(SoundManager.boss_flame, self)
