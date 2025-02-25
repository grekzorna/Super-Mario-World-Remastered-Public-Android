extends BoomBossClass

func enter(_msg := {}) -> void:
	await get_tree().physics_frame
	if CoopManager.pipe_exiting:
		await CoopManager.players_exited_pipe
	boss.animations.play("Intro")
	for i in CoopManager.active_players.values():
		if is_instance_valid(i):
			i.state_machine.transition_to("Freeze", {"Gravity"=true})
	await get_tree().create_timer(2, false).timeout
	state_machine.transition_to("Run")

func exit() -> void:
	for i in CoopManager.active_players.values():
		i.state_machine.transition_to("Normal")
