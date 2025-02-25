class_name PlayerHurtbox
extends Area2D

func _ready() -> void:
	area_entered.connect(entered)

func entered(area: Area2D) -> void:
	if area.owner is Player:
		area.owner.damage()
