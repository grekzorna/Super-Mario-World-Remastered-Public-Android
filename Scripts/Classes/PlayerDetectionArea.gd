class_name PlayerDetectionArea
extends Area2D

signal player_entered(player)

func _ready() -> void:
	area_entered.connect(on_area_entered)

func on_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		player_entered.emit(area.owner)
