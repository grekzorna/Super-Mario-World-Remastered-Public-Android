extends Level

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		TransitionManager.transition_to_map(("res://Instances/Levels/Maps/YoshiIsland.tscn"), self)
