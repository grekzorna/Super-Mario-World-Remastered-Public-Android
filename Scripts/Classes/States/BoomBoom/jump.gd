extends BoomBossClass

var target_player: Player = null

var charging := false
var jumping := false
var landing := false
var can_hit_wall := true
var jump_direction := 1

func enter(_msg := {}) -> void:
	can_hit_wall = true
	charging = true
	jumping = false
	landing = false
	SoundManager.play_sfx(SoundManager.jump_charge, boss)
	boss.animations.play("JumpCharge")
	boss.velocity.x = 0
	await get_tree().create_timer(0.5, false).timeout
	if state_machine.state == self:
		jump()

func physics_update(_delta: float) -> void:
	target_player = CoopManager.get_closest_player(boss.global_position)
	boss.direction = jump_direction
	if charging:
		if target_player.global_position.x > boss.global_position.x:
			jump_direction = 1
		else:
			jump_direction = -1
	boss.velocity.y += 10
	if jumping:
		if boss.is_on_wall() and can_hit_wall:
			can_hit_wall = false
			boss.velocity.x = -150 * jump_direction
			jump_direction *= -1
			await get_tree().physics_frame
			can_hit_wall = true
			
		if boss.is_on_floor():
			land()

func jump() -> void:
	charging = false
	SoundManager.play_sfx(SoundManager.spring, boss)
	boss.velocity.y = -350
	boss.velocity.x = 150 * jump_direction
	jumping = true

func land() -> void:
	jumping = false
	landing = true
	boss.animations.play("Land")
	boss.velocity.x = 0
	await get_tree().create_timer(1, false).timeout
	if state_machine.state == self:
		if boss.spiky_head == false:
			state_machine.transition_to("Shell")
		else:
			state_machine.transition_to("Run")
