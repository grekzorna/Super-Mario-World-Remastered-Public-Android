extends State

var dir := 1
var jumping := false

func enter(_msg := { }) -> void:
	owner.hitbox.set_deferred("monitoring", false)
	owner.sprite.flip_h = true
	jumping = false
	await get_tree().create_timer(1, false).timeout
	jumping = true
	if owner.global_position.x > 256:
		owner.direction = -1
	else:
		owner.direction = 1
	if owner.direction == -1:
		owner.animations.play("JumpL")
	else:
		owner.animations.play("JumpR")
	SoundManager.play_sfx(SoundManager.spring, owner)
	await owner.animations.animation_finished
	state_machine.transition_to("Fire")
	owner.hitbox.set_deferred("monitoring", true)
	owner.scale.x = 1
	owner.can_hurt = true
	owner.sprite.flip_h = false

func physics_update(delta: float) -> void:
	if jumping:
		owner.global_position.x += 64 * owner.direction * delta
