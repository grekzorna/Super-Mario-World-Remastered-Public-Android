extends Enemy

var jump_height := -90

@onready var initial_position := global_position + Vector2(0, 8)

var lava_height := -64

var can_jump := false

var falling := true

const gravity := 8

func _physics_process(delta: float) -> void:
	can_jump_on = visible
	if falling:
		velocity.y += gravity
	sprite.flip_v = velocity.y > 0
	if can_jump and $VisibleOnScreenNotifier2D.is_on_screen():
		can_jump = false
		await get_tree().create_timer(1, false).timeout
		jump()
	move_and_slide()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is LavaArea:
		sprite.hide()
		lava_height = area.get_parent().global_position.y
		jump_height = abs(lava_height - initial_position.y)
		falling = false
		velocity.y = 0
		await get_tree().create_timer(4, false).timeout
		can_jump = true

func jump() -> void:
	can_jump = false
	sprite.show()
	global_position.y = lava_height
	falling = true
	velocity.y = -sqrt(2 * gravity * jump_height) * 8 ## thanks alex your so smart xx
	SoundManager.play_sfx(SoundManager.boss_flame, self)
