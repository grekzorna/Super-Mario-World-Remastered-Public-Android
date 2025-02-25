extends Node

@onready var areas := ["YoshiIsland", "DonutPlains", "VanillaDome", "TwinBridge", "IllusionForest", "ChocoIsland", "BowserValley", "StarRoad", "SpecialWorld", "SMBW1"]

var fucked_levels := []

func _ready() -> void:
	for i in areas:
		for x in DirAccess.get_files_at("res://Instances/Levels/" + i):
			var path = "res://Instances/Levels/" + i + "/" + x.replace(".remap", "")
			var check = load(path)
			if is_instance_valid(check) == false:
				fucked_levels.append(path)
	write_to_file()

func write_to_file() -> void:
	var file = FileAccess.open("user://FuckedLevels.cum", FileAccess.WRITE)
	for i in fucked_levels:
		file.store_string(i + "\n")
	file.close()
