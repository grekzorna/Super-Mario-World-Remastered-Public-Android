extends Node

func _ready() -> void:
	await get_tree().physics_frame
	for i in CoopManager.alive_players.values():
		i.riding_yoshi = true
		i.yoshi_colour = 2
		i.yoshi_perma_fly = true
		i.yoshi_flying = true
