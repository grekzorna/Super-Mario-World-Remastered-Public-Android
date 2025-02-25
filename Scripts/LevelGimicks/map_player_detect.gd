extends Node2D

signal player_entered

func _on_area_area_entered(area: Area2D) -> void:
	if area.get_parent() is MapPlayer:
		player_entered.emit()
