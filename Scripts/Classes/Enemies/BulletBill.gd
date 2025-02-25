extends Enemy

const move_speed := 100

@export var direction_vector := Vector2.ZERO
@onready var flame: AnimatedSprite2D = $Sprite/Flame

func _physics_process(delta: float) -> void:
	global_position += (move_speed * direction_vector) * delta
	sprite.rotation = direction_vector.angle() + deg_to_rad(180)
	sprite.scale.y = -direction_vector.x

func damage() -> void:
	die()

func _ready() -> void:
	if GameManager.autumn:
		sprite.queue_free()
		sprite = $AutumnSprite
		sprite.play(str(SettingsManager.sprite_settings.pidget))
		sprite.show()
	SoundManager.play_sfx(SoundManager.bullet, self)
	await get_tree().physics_frame
	if direction_vector == Vector2.ZERO:
		if direction == -1:
			direction_vector = Vector2.LEFT
		else:
			direction_vector = Vector2.RIGHT


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
