class_name OnOffRailJunction
extends Node

var active := true

func _ready() -> void:
	for i in GameManager.current_level.get_children():
		if i is OnOffSwitch:
			i.changed.connect(change)

func _process(delta: float) -> void:
	if is_instance_valid(on_rail):
		on_rail.visible = active
	if is_instance_valid(off_rail):
		off_rail.visible = not active

func change() -> void:
	active = !active

@export var on_rail: Rail
@export var off_rail: Rail
