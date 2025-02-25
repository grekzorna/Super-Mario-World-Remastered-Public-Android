extends Block
const _1_UP = preload("res://Instances/Prefabs/Items/1_up.tscn")

signal one_up_dispensed

func block_hit_override(direction := "") -> void:
	if GameManager.coins_in_level >= 30:
		summon_item(_1_UP)
		one_up_dispensed.emit()
		SoundManager.play_sfx(SoundManager.correct, self)
		empty_block()
	else:
		SoundManager.play_sfx(SoundManager.wrong, self)
		dispense_coin()
		empty_block()
