extends Enemy

const move_speed := 75

var can_play := true

var can_move := true

var hi
@onready var visible_on_screen_enabler_2d: VisibleOnScreenEnabler2D = $VisibleOnScreenEnabler2D

@export var starting_direction := 1

func _ready() -> void:
	direction = starting_direction
	visible_on_screen_enabler_2d.position.x = -85 if direction ==1 else -22
	sprite.scale.x = direction

func _physics_process(delta: float) -> void:
	if can_move:
		global_position.x += (-move_speed * direction) * delta
	else:
		velocity.y += 15
	move_and_slide()
func _on_visible_on_screen_enabler_2d_screen_entered() -> void:
	if can_play:
		SoundManager.play_sfx(SoundManager.bullet, self)
		can_play = false

func damage() -> void:
	can_move = false
	await get_tree().create_timer(1, false).timeout
	queue_free()
