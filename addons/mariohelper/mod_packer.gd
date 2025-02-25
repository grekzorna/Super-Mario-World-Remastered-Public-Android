@tool
extends Control

@onready var file_path: LineEdit = $MarginContainer/Container/HBoxContainer/AddFile/VBoxContainer/FilePath
@onready var add_path: Button = $MarginContainer/Container/HBoxContainer/AddFile/VBoxContainer/AddPath
@onready var clear_list: Button = $MarginContainer/Container/HBoxContainer/AddFile/VBoxContainer/ClearList
@onready var pck_path: LineEdit = $MarginContainer/Container/HBoxContainer/AddFile2/VBoxContainer/PCKPath
@onready var export_pck: Button = $MarginContainer/Container/HBoxContainer/AddFile2/VBoxContainer/ExportPCK
@onready var item_list: ItemList = $MarginContainer/Container/ItemList



func _on_add_path_pressed() -> void:
	item_list.add_item(file_path.text)
	file_path.clear()

func _on_clear_list_pressed() -> void:
	file_path.clear()
	item_list.clear()

func _on_export_pck_pressed() -> void:
	var packer = PCKPacker.new()
	DirAccess.make_dir_absolute("user://ExportedAddons")
	var file_name = pck_path.text.replace(".pck", "")
	var file_path = ("user://ExportedAddons/" + file_name + ".pck")
	packer.pck_start(file_path)
	for i in item_list.get_item_count():
		packer.add_file(file_path, item_list.get_item_text(i))
	packer.flush()
	OS.alert(".pck has been made at: " + file_path)

var checking_files = []
var dupe_files := []
var directories = []

var user_path = "user://CustomLevels/"

var search_target = ""
var replace_target = ""
var raw_files = []

func uid_fix() -> void:
	checking_files.clear()
	get_files("res://")
	update_uids()

var folder_name := ""

var level_folder_path := ""
var level_info_path := ""
var level_name := ""
var export_level_path = "user://CustomLevels/" + level_name

func export_level() -> void:
	level_folder_path = $TabContainer/Levels/MarginContainer/Container/HBoxContainer/LevelExport.text
	checking_files = []
	directories = []
	raw_files = []
	dupe_files.clear()
	level_info_path = $TabContainer/Levels/MarginContainer/Container/HBoxContainer2/LevelInfo.text
	var split = level_info_path.split("/")
	level_name = split[split.size() - 1].replace(".tres", "")
	export_level_path = "user://CustomLevels/" + level_name
	print(export_level_path)
	DirAccess.make_dir_recursive_absolute(export_level_path)
	get_files(level_folder_path)
	make_directories()
	check_files()
	create_json(load(level_info_path))
	OS.alert("Exported!")
	OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://CustomLevels"))

func create_json(info: LevelInfo) -> void:
	var json = {}
	
	for i in [
		"level_title", 
		"level_scene_path", 
		"start_cutscene_path",
		"has_secret_exit", 
		"yoshi_allowed", 
		"has_dragon_coins", 
		"title_image"
		]:
		
		var val = info.get(i)
		if val is String:
			val = val.replace(level_folder_path, export_level_path)
		json[i] = val
	var text = JSON.new().stringify(json, "\t")
	var file = FileAccess.open(export_level_path + "/levelinfo.json", FileAccess.WRITE)
	file.store_string(text)
	file.close()

func make_directories() -> void:
	for i in directories:
		print(i)
		DirAccess.make_dir_recursive_absolute("user://CustomLevels/" + i)

func check_files() -> void:
	var text_lines = []
	for i in checking_files:
		if i.contains(".import"):
			get_import_files(i)
		var file = FileAccess.open(i, FileAccess.READ)
		var file_text = file.get_as_text()
		var new_lines = []
		text_lines = file_text.split("\n")
		var index := 0
		for x in text_lines:
			new_lines.append(x)
		var new_file = FileAccess.open(i.replace(level_folder_path, export_level_path), FileAccess.WRITE)
		for y in new_lines:
			y = replace_uids(y)
			new_file.store_line(y)
		new_file.close()
		file.close()
	for i in dupe_files:
		DirAccess.copy_absolute(i, i.replace(level_folder_path, export_level_path))

func get_import_files(import_file := "") -> void:
	print("HIIIII" + import_file)
	var file = FileAccess.open(import_file, FileAccess.READ)
	var file_text = file.get_as_text()
	var new_lines = []
	var text_lines = file_text.split("\n")
	DirAccess.make_dir_recursive_absolute(export_level_path + "/imported")
	for i in text_lines:
		if i.contains("path="):
			var import_path = i.split("path=")[1]
			duplicate_import_file(import_path)

func duplicate_import_file(file := "") -> void:
	file = file.split("/")[file.split("/").size() - 1].replace('"', "")
	DirAccess.copy_absolute("res://.godot/imported/" + file, (export_level_path + "/imported/" + file))

func replace_uids(line := "") -> String:
	var new_line := ""
	if line.contains(level_folder_path):
		if line.contains("uid="):
			var uid_pos = 0
			uid_pos = line.find("uid=", uid_pos)
			var uid = line.substr(uid_pos, 25)
			new_line = line.replace(uid, "")
			new_line = new_line.replace(level_folder_path, export_level_path)
			return new_line
		else:
			return line.replace(level_folder_path, export_level_path)
	elif line.contains("path="):
		new_line = line.replace("res://.godot", "user://CustomLevels/" + level_name)
		return new_line
	else:
		return line
	 
func get_files(path) -> void:
	var current_file_path = path
	for i in DirAccess.get_directories_at(current_file_path):
		get_files(current_file_path + "/" + i)
	for x in DirAccess.get_files_at(current_file_path):
		var files_to_replace := [".tres", ".tscn", ".import", ".gd"]
		for i in files_to_replace:
			if x.contains(i):
				checking_files.append(current_file_path + "/" + x)
				break
			elif i == files_to_replace[files_to_replace.size() - 1]:
				dupe_files.append(current_file_path + "/" + x)
	print(checking_files, dupe_files)

func update_uids() -> void:
	var index := 0
	for i in checking_files:
		if i.contains("addons/"):
			checking_files.remove_at(index)
		index += 1
	var i = checking_files[0]
	var file = FileAccess.open(i, FileAccess.READ_WRITE)
	var file_text = file.get_as_text()
	var file_lines = file_text.split("\n")
	for line in file_lines:
		if line.contains("uid"):
			pass
		var uid_line = ""
