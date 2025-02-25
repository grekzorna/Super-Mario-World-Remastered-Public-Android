extends Enemy

var can_bounce := true
@onready var animations: AnimationPlayer = $Sprite/Animations

func _ready() -> void:
	animations.play("Spin" + str(direction))

func _physics_process(delta: float) -> void:
	velocity.y += 25
	if is_on_floor():
		if can_bounce:
			SoundManager.play_sfx(SoundManager.bullet, self)
			velocity.y = -150
			can_bounce = false
		velocity.x = 100 * direction
	if global_position.y > 128:
		queue_free()
	move_and_slide()
