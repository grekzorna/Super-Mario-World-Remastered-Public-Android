class_name PowerScript
extends Node

@onready var player: Player = get_parent()

func _physics_process(delta: float) -> void:
	physics_update(delta)

func _process(delta: float) -> void:
	update(delta)

func _ready() -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func update(_delta: float) -> void:
	pass
