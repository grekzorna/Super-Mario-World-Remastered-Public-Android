extends Level

@export_range(1, 3) var mode := 1 ## The mode used for the target pipe destination (1 = coins, 2 = time, 3 = dragon coins)
@export var pipe_target: Pipe = null

var destination := ""

func _physics_process(delta: float) -> void:
	destination = "res://Instances/Levels/ChocoIsland/CI2/"
	match mode:
		1:
			mode_1()
		2:
			mode_2()
		3:
			mode_3()
	pipe_target.level_scene = destination + ".tscn"

func mode_1() -> void:
	if GameManager.coins_in_level > 21:
		destination += "c"
	elif GameManager.coins_in_level > 9 and GameManager.coins_in_level < 21:
		destination += "b"
	else:
		destination += "a"

func mode_2() -> void:
	if GameManager.time > 250:
		destination += "d"
	elif GameManager.time > 235 and GameManager.time < 249:
		destination += "e"
	else:
		destination += "f"

func mode_3() -> void:
	if GameManager.dragon_coins == 4:
		destination += "h"
	else:
		destination += "g"
