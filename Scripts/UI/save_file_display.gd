class_name SaveContainer
extends NinePatchRect

@export var save = {}
var selected := false
@onready var file_title: Label = $FileTitle

@onready var valid_file: Control = $ValidFile
@onready var empty_file: Control = $EmptyFile
@onready var delete_tag: NinePatchRect = $DeleteTag

@onready var egg_container: GridContainer = $ValidFile/EggContainer
@onready var star_count: Label = $ValidFile/StarPoints/Label
@onready var switch_blocks: HBoxContainer = $ValidFile/SwitchBlocks
@onready var lives: Label = $ValidFile/PlayerCharacter/Lives

const PLAYER_LABELS = [preload("res://Assets/Sprites/UI/HUD/MarioTitle.png"), preload("res://Assets/Sprites/UI/HUD/LuigiTitle.png")]

@onready var player_character: TextureRect = $ValidFile/PlayerCharacter

@export var file_index := 0

func _ready() -> void:
	file_title.text = "File " + get_index_letter()

func _process(delta: float) -> void:
	if selected:
		position.y = -16
	else:
		position.y = 0
	delete_tag.visible = Input.is_action_pressed("delete_save") and selected and save != null

func update_display() -> void:
	apply_save()

func get_index_letter() -> String:
	var letter = ""
	match file_index:
		0:
			letter = "A"
		1:
			letter = "B"
		2:
			letter = "C"
	return letter

func get_save_data() -> void:
	save = SaveManager.get_data(file_index)
	update_display()

func apply_save() -> void:
	if save == {} or save == null:
		valid_file.hide()
		empty_file.show()
		if FileAccess.file_exists("user://" + str(file_index) + ".sav"):
			DirAccess.remove_absolute("user://" + str(file_index) + ".sav")
			SaveManager.save_data(SaveManager.save_file_template, file_index)
		return
	valid_file.show()
	empty_file.hide()
	$ValidFile/Crown.visible = save.game_beaten
	star_count.text = str(GameManager.calculate_total_exits(save))
	$ValidFile/Lives.text = str(int(save.lives))
	$ValidFile/Coins.text = str(GameManager.calculate_total_drag_coins(save))
	var index = 0
	for i in egg_container.get_children():
		print(save.eggs_rescued)
		if save.eggs_rescued[index]:
			i.texture = i.collected_texture
		index += 1
	index = 0
	for i in switch_blocks.get_children():
		print(save.colours_enabled)
		if save.colours_enabled[i.id]:
			i.texture = i.full_texture
		index += 1
