
extends AnimatedSprite2D

func delete() -> void:
	if Engine.is_editor_hint() == false:
		queue_free()
