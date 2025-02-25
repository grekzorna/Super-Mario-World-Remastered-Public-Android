@tool
class_name OptionNode
extends Control

@export var title: Label = null

@export var highlighted := true

@export var settings_value := ""

var lowest_value := false
var highest_value := false

func update(delta: float) -> void:
	pass

func _process(delta: float) -> void:
	update(delta)
	
	title.modulate = Color.YELLOW if highlighted else Color.WHITE
