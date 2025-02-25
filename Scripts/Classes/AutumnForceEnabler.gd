class_name AutumnForceEnabler
extends Node

@export var enabled := true

func _enter_tree() -> void:
	GameManager.autumn = enabled
