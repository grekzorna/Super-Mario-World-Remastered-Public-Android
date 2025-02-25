@tool
extends Control


var global_frames = []
var global_frame_speeds = {}
var global_frame_loops = {}

var files := {}

const faster_frames = {"Flip": 20, "Spin": 20}
@onready var line_edit: LineEdit = $GridContainer/VBoxContainer2/LineEdit
@onready var file_path_list: ItemList = $VBoxContainer/FilePathList

const sprite_path = ("res://Resources/PlayerSpriteFrames/Mario/")
var sprite = ""
var base_sprite_frames: SpriteFrames = null


func get_frames() -> void:
	sprite = line_edit.text + ".tres"
	base_sprite_frames = load(sprite_path + sprite)
	global_frames = []
	for i in base_sprite_frames.get_animation_names():
		global_frames.append(i)
		global_frame_speeds[i] = base_sprite_frames.get_animation_speed(i)
		global_frame_loops[i] = base_sprite_frames.get_animation_loop(i)

func add_frames() -> void:
	
	get_frames()
	var frames = SpriteFrames.new()
	for animation in global_frames:
		frames.add_animation(animation)
		frames.set_animation_speed(animation, global_frame_speeds[animation])
		frames.set_animation_loop(animation, global_frame_loops[animation])
		if faster_frames.has(animation):
			frames.set_animation_speed(animation, faster_frames[animation])
	frames.remove_animation("default")
	ResourceSaver.save(frames, "res://Resources/PlayerSpriteFrames/" + sprite)

func get_all_files() -> void:
	pass


const LEVEL_BG = preload("res://Instances/Prefabs/level_bg.tscn")
const PLAYER = preload("res://Instances/Prefabs/Player.tscn")
const TILE_MAP = preload("res://Instances/Prefabs/tile_map.tscn")

func _on_button_pressed() -> void:
	var hack = EditorScript.new()
	var scene = hack.get_editor_interface().get_edited_scene_root()
	var bg = LEVEL_BG.instantiate()
	scene.add_child(bg)
	bg.owner = scene
	var player = PLAYER.instantiate()
	scene.add_child(player)
	player.owner = scene
	var tile_map = TILE_MAP.instantiate()
	scene.add_child(tile_map)
	tile_map.owner = scene
	var level_guide = Sprite2D.new()
	level_guide.z_index = -10
	level_guide.position = Vector2(-64, -384)
	level_guide.centered = false
	level_guide.modulate = Color.DIM_GRAY
	scene.add_child(level_guide)
	level_guide.name = "LevelGuide"
	level_guide.owner = scene
	
func clean_export_files(dir := "") -> void:
	for i in DirAccess.get_directories_at(dir):
		clean_export_files(dir + "/" + i)
	for i in DirAccess.get_files_at(dir):
		if i.contains(".import"):
			if FileAccess.file_exists(dir + "/" + i.replace(".import", "")) == false:
				DirAccess.remove_absolute(dir + "/" + i)


func _on_clear_list_pressed() -> void:
	file_path_list.clear()
	$FilePath.clear()


func _on_add_path_pressed() -> void:
	file_path_list.add_item($FilePath.text)
	$FilePath.clear()


func _on_export_pressed() -> void:
	var packer = PCKPacker.new()
	DirAccess.make_dir_absolute("user://ExportedAddons")
	var file_name = $Export.text.replace(".pck", "")
	var file_path = ("user://ExportedAddons/" + file_name + ".pck")
	packer.pck_start(file_path)
	for i in file_path_list.get_item_count():
		packer.add_file(file_path, file_path_list.get_item_text(i))
	packer.flush()
	OS.alert(".pck has been made at: " + file_path)
