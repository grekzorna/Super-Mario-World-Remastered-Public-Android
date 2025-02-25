extends Control

const CHARACTER_CONTAINER = preload("res://Instances/UI/character_container.tscn")

var can_select := true

signal finished

@onready var cursors := [$P1Cursor, $P2Cursor, $P3Cursor, $P4Cursor]

var is_open := false

var character_containers := []

var player_characters := {0: null, 1: null, 2: null, 3: null}
var player_character_slots := {0: null, 1: null, 2: null, 3: null}

var selected := {0: false, 1: false, 2: false, 3: false}

var characters: Array[CharacterResource] = []

var all_players_selected := false

var locked := false

@onready var confirmation: Label = $Confirmation

func _ready() -> void:
	get_characters()

func _physics_process(delta: float) -> void:
	if is_open == false:
		return
	handle_cursors()
	all_players_selected = false
	var arr = []
	for i in selected.values():
		if i:
			arr.append(i)
	all_players_selected = arr.size() >= CoopManager.players_connected
	confirmation.visible = all_players_selected
	if all_players_selected:
		if Input.is_action_just_pressed("ui_accept"):
			apply()

func apply() -> void:
	locked = true
	CoopManager.player_characters = player_characters
	var index := 0
	for i in player_characters.values():
		if is_instance_valid(i):
			if i.override_power_state != null:
				CoopManager.player_power_overrides[index] = i.override_power_state
		index += 1
	finished.emit()

func handle_cursors() -> void:
	var cursor_index := 0
	for i in cursors:
		if cursor_index < CoopManager.players_connected:
			i.show()
			handle_cursor_movement(cursor_index)
		else:
			i.hide()
		cursor_index += 1

func handle_cursor_movement(id := 0) -> void:
	if selected[id]:
		if Input.is_action_just_pressed(CoopManager.get_player_input_str("run", id)) and not locked:
			SoundManager.play_ui_sound(SoundManager.fireball)
			selected[id] = false
			player_character_slots[id].selected = false
		return
	var vector = Input.get_vector(CoopManager.get_player_input_str("move_left", id),
									CoopManager.get_player_input_str("move_right", id),
									CoopManager.get_player_input_str("move_up", id),
									CoopManager.get_player_input_str("move_down", id))
	cursors[id].global_position += vector * 2
	cursors[id].global_position.y = clamp(cursors[id].global_position.y, 0, 270)
	cursors[id].global_position.x = clamp(cursors[id].global_position.x, 0, 480)
	if cursors[id].get_node("Area").get_overlapping_areas().is_empty():
		player_character_slots[id] = null
	elif cursors[id].get_node_or_null("Area") != null:
		player_character_slots[id] = cursors[id].get_node("Area").get_overlapping_areas()[0].get_parent()
		player_characters[id] = player_character_slots[id].character
	for i in character_containers:
		i.hovered = player_character_slots.values().has(i)
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("jump", id)):
		if player_characters[id] != null:
			SoundManager.play_ui_sound(player_characters[id].selection_sfx)
			await get_tree().process_frame
			player_character_slots[id].selected = true
			selected[id] = true
	if player_character_slots[id] != null:
		if Input.is_action_just_pressed("ui_tab_left"):
			player_character_slots[id].index -= 1
			SoundManager.play_ui_sound(SoundManager.select)
		elif Input.is_action_just_pressed("ui_tab_right"):
			player_character_slots[id].index += 1
			SoundManager.play_ui_sound(SoundManager.select)

func close() -> void:
	hide()
	is_open = false

func open() -> void:
	show()
	player_characters = {0: null, 1: null, 2: null, 3: null}
	player_character_slots = {0: null, 1: null, 2: null, 3: null}
	selected = {0: false, 1: false, 2: false, 3: false}
	for i in character_containers:
		i.selected = false
	await get_tree().physics_frame
	is_open = true

func get_characters() -> void:
	const res_path := "res://Resources/Characters/"
	characters.clear()
	for i in DirAccess.get_files_at("res://Resources/Characters/"):
		characters.append(load(res_path + i.replace(".remap", "")))
	add_characters()

func add_characters() -> void:
	characters.sort_custom(func(a, b): return a.character_id < b.character_id)
	var index := 0
	for i in characters:
		if i.character_skin != null:
			if characters.has(i.character_skin):
				character_containers[characters.find(i.character_skin)].skins.append(i)
		else:
			var node = CHARACTER_CONTAINER.instantiate()
			node.character = i
			$CenterContainer/GridContainer.add_child(node)
			character_containers.append(node)
		index += 1


func _on_custom_level_select_level_selected() -> void:
	pass # Replace with function body.
