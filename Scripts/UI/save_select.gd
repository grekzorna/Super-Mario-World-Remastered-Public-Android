extends Control

var active := false

var selected_index := 0
var selected_save: Node = null
@onready var saves = [$SaveContainer/Save1, $SaveContainer/Save2, $SaveContainer/Save3]
@onready var sub_selections := [$LevelSelect]
@onready var animations: AnimationPlayer = $Animations
@onready var music: AudioStreamPlayer = $Music
@onready var arrow: CenterContainer = $Arrow
@onready var level_select: NinePatchRect = $LevelSelect
@onready var sub_arrow: CenterContainer = $SubArrow

var can_enter := true


var locked := false

signal closed
signal save_selected
signal custom_levels_selected
signal campaign_selected

func _process(delta: float) -> void:
	arrow.visible = active
	if active:
		if can_enter:
			if Input.is_action_just_pressed("ui_left"):
				selected_index -= 1
				SoundManager.play_ui_sound(SoundManager.menu)
			if Input.is_action_just_pressed("ui_right"):
				selected_index += 1
				SoundManager.play_ui_sound(SoundManager.menu)
		selected_index = clamp(selected_index, 0, saves.size() - 1)
		if selected_index >= 0:
			selected_save = saves[selected_index]
			arrow.global_position.x = selected_save.global_position.x + 39
		if Input.is_action_just_pressed("ui_accept"):
			if Input.is_action_pressed("delete_save") and selected_save.save != null:
				delete_save()
			elif selected_index >= 0:
				close()
				save_selected.emit()
				active = false
			else:
				custom_levels_selected.emit()
		if Input.is_action_just_pressed("ui_back"):
			closed.emit()
			SoundManager.play_ui_sound(SoundManager.fireball)
			close()
			
	else:
		selected_save = null
	for i in saves:
		i.selected = selected_save == i

func delete_save() -> void:
	SaveManager.selected_file = 0
	SaveManager.save_data(SaveManager.save_file_template, selected_index)
	SoundManager.play_ui_sound(SoundManager.thunder)
	SoundManager.play_ui_sound(SoundManager.bullet)
	SoundManager.play_ui_sound(SoundManager.boss_flame)
	DirAccess.remove_absolute("user://Saves/" + GameManager.current_campaign.title +"/" + str(selected_index) + ".sav")
	selected_save.save = null
	SaveManager.current_save = {}
	selected_save.update_display()

func close() -> void:
	active = false
	hide()

func enter() -> void:
	for i in saves:
		i.get_save_data()
	show()
	await get_tree().physics_frame
	active = true

func enter_game() -> void:
	if can_enter:
		can_enter = false
	else:
		return
	active = false
	SaveManager.load_file(selected_index)
	print("Loaded Save")
	SaveManager.selected_file = selected_index
	#print(SaveManager.current_save.current_map)
	var save = SaveManager.current_save
	SoundManager.play_ui_sound(SoundManager.enter_save)
	
	GameManager.map_point_save = save.map_point_name
	print("fuck: " + save.map_point_name)
	SaveManager.apply_data()
	await get_tree().create_timer(1).timeout
	GameManager.map_point_save = save.map_point_name
	await get_tree().create_timer(0.5).timeout

	
	if save.current_map == "":
		if GameManager.current_campaign.starting_scene != "":
			TransitionManager.transition_to_level(GameManager.current_campaign.starting_scene, owner)
		else:
			TransitionManager.transition_to_map(GameManager.current_campaign.starting_map, owner)
		GameManager.current_map_path = GameManager.current_campaign.starting_map
	else:
		print(save.current_map)
		TransitionManager.transition_to_map((save.current_map), owner, false, GameManager.map_point_save)
