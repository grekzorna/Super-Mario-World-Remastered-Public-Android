class_name CutsceneLevel
extends Level

@onready var players := [$Players/Player1, $Players/Player2, $Players/Player3, $Players/Player4]

func spawn() -> void:
	
	for i in players:
		i.hide()
	for i in CoopManager.players_connected:
		players[i].show()
	
	for i in 4:
		players[i].character = CoopManager.player_characters[i]
		players[i].power_state = load(CoopManager.player_power_states[i])

func cutscene_finish() -> void:
	TransitionManager.transition_to_level(TransitionManager.cutscene_level, self, false)
