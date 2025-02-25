@tool
extends Control

var holes: Array[Control] = []

@export var colour := Color.BLACK

func _process(delta: float) -> void:
	get_holes()
	print(holes)
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), colour)
	for i in holes:
		draw_rect(i.get_global_rect(), Color(1, 0, 0, 0.0))

func get_holes() -> void:
	holes.clear()
	for i in get_children():
		if i is Control:
			holes.append(i)
