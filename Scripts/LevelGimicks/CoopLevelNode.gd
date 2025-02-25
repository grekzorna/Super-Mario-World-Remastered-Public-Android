class_name CoopReplaceNode
extends ConditionalReplaceNode

@export var target_players := 1

func condition() -> bool:
	return CoopManager.players_connected >= target_players
