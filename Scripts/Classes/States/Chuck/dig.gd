extends ChuckState
const CHUCK_ROCK = preload("res://Instances/Prefabs/Enemies/chuck_rock.tscn")
func enter(_msg := {}) -> void:
	await get_tree().physics_frame
	loop()

func physics_update(delta: float) -> void:
	chuck.velocity.y += 15
	chuck.move_and_slide()

func loop() -> void:
	for i in 3:
		chuck.animations.play("Dig")
		await chuck.animations.animation_finished
		if state_machine.state != self:
			return
	chuck.animations.play("DigIdle")
	await get_tree().create_timer(2, false).timeout
	loop()

func summon_rock() -> void:
	SoundManager.play_sfx("res://Assets/Audio/SFX/hammer-bro-throw.wav", chuck)
	var node =  CHUCK_ROCK.instantiate()
	node.global_position = chuck.global_position + Vector2(8 * chuck.direction, 0)
	node.direction = chuck.direction
	GameManager.current_level.add_child(node)
