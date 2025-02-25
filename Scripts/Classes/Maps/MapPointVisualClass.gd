class_name MapPointVisual
extends Node2D

@onready var map_point: MapPoint = get_parent()
@export var always_show := false

signal completed_animation

var completed := false

func _ready() -> void:
	pass

func on_unlock() -> void:
	pass
