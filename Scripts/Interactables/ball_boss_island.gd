extends AnimatableBody2D

var tilt := 0.0

var tilt_times := 0

var tilt_direction := 1

var can_tilt := true

func _ready() -> void:
	_on_timer_timeout()




func _on_timer_timeout() -> void:
	if can_tilt == false:
		return
	tilt_times += 1
	tilt_direction *= -1
	tilt_times = wrap(tilt_times, 1, 6)
	tween_tilt((15 * tilt_times) * tilt_direction)

func tween_tilt(new_tilt := 0.0) -> void:
	var tween = create_tween()
	tween.tween_property(self, "global_rotation_degrees", new_tilt, 2).as_relative()
