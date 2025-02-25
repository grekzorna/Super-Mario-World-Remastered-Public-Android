extends Node

func _ready() -> void:
	CoopManager.players_connected = clamp(CoopManager.players_connected, 2, 4)
	CoopManager.splitscreen = true
	GameManager.vs_mode = true
