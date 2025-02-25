extends Node

var save_file_0 := {}
var save_file_1 := {}
var save_file_2 := {}

var current_save := {}
var selected_file = 0

var saves := []

const SMALL = ("res://Resources/PlayerPowerUpState/Small.tres")

var save_file_template := {
	"lives": 5,
	"coins": 0,
	"score": 0,
	"star_points": 0,
	"unlocked_levels": [],
	"beaten_levels": [],
	"special_beaten_levels": [],
	"dragon_levels": [],
	"dragon_coins_collected": {},
	"eggs_rescued": [false, false, false, false, false, false, false],
	"colours_enabled": [false, false, false, false],
	"current_map": "",
	"map_point_name": "",
	"reserved_item": null,
	"achievements_unlocked": [],
	"player_power_states": [SMALL, SMALL, SMALL, SMALL],
	"player_yoshis": [false, false, false, false],
	"yoshi_colours": [0, 0, 0, 0],
	"seen_yoshi_message": [false, false, false, false],
	"time_played": 0.0,
	"game_beaten": false,
	"autumn": false,
	"autumn_unlocked": false,
	"peach_coins_unlocked": false,
	"peach_coins_collected": []
}

func load_file(file_index) -> void:
	if FileAccess.file_exists("user://Saves/" + GameManager.current_campaign.title + "/" + str(file_index) + ".sav") == false:
		save_data(save_file_template, file_index)
	current_save = {}
	current_save = get_data(file_index)

func verify_save(file := {}) -> Dictionary:
	for i in save_file_template.keys():
		if file.has(i) == false:
			file[i] = save_file_template[i]
	return file

func save_current_file() -> void:
	save_data(current_save, selected_file)

func save_data(save_file := {}, file_index := 0) -> void:
	GameManager.save_animation.play("Appear")
	GameManager.apply_to_save()
	DirAccess.make_dir_recursive_absolute("user://Saves/" + GameManager.current_campaign.title)
	var data = var_to_str(save_file)
	var file = FileAccess.open("user://Saves/" + GameManager.current_campaign.title + "/" + str(file_index) + ".sav", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_file, "\t"))
	file.close()

func get_data(file_index):
	if FileAccess.file_exists("user://Saves/" + GameManager.current_campaign.title + "/" + str(file_index) + ".sav"):
		var file = FileAccess.open("user://Saves/" + GameManager.current_campaign.title + "/" + str(file_index) + ".sav", FileAccess.READ)
		var new_file = JSON.parse_string(file.get_as_text())
		file.close()
		new_file = verify_save(new_file)
		print(new_file)
		return new_file
	return 

func is_level_in_array(level_name := "", array = []) -> bool:
	return array.has(level_name)

func apply_data() -> void:
	GameManager.apply_save()
