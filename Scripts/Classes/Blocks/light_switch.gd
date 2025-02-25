class_name LightSwitch
extends Block

var can_switch := true

signal activated

func block_hit_override(direction := "Up") -> void:
	if can_switch == false:
		return
	can_switch = false
	activated.emit()
	SoundManager.play_sfx(SoundManager.switch_activate, self)
	await get_tree().create_timer(0.5, false).timeout
	can_switch = true
