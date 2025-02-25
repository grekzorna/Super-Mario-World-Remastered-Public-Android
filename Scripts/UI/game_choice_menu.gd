extends Node

var active := false

@onready var setting_nodes = [$HBoxContainer/Local, $HBoxContainer/Online]
@onready var pointer: CenterContainer = $Pointer
@onready var animations: AnimationPlayer = $Animations

var selected_node: Node = null
var selected_index := 0

var can_select := true

signal online_selected
signal local_selected
signal closed

func _process(delta: float) -> void:
	if active:
		selected_node = setting_nodes[selected_index]
		handle_pointer(delta)
		handle_settings_nodes(delta)
		if Input.is_action_just_pressed("ui_accept"):
			option_select()
	pointer.visible = active

func enter() -> void:
	animations.play("Show")
	await animations.animation_finished
	active = true

func leave() -> void:
	animations.play_backwards("Show")
	active = false

func handle_pointer(delta) -> void:
	if can_select:
		if Input.is_action_just_pressed("ui_left"):
			selected_index -= 1
			SoundManager.play_ui_sound(SoundManager.menu)
		elif Input.is_action_just_pressed("ui_right"):
			selected_index += 1
			SoundManager.play_ui_sound(SoundManager.menu)
	selected_index = clamp(selected_index, 0, setting_nodes.size() - 1)
	pointer.global_position.x = lerpf(pointer.global_position.x, selected_node.global_position.x + (selected_node.size.x / 2), delta * 20)

func handle_settings_nodes(delta) -> void:
	for i in setting_nodes:
		if selected_node == i:
			i.global_position.y = lerpf(i.global_position.y, 208 - 24, delta * 20)
		else:
			i.global_position.y = lerpf(i.global_position.y, 208 - 8, delta * 20)

func option_select() -> void:
	if can_select:
		can_select = false
	else:
		return
	SoundManager.play_ui_sound(SoundManager.correct)
	await flash_animation(selected_node)
	leave()
	match selected_index:
		0:
			local_selected.emit()
		1:
			online_selected.emit()
			TransitionManager.transition_to_menu("res://Instances/Levels/multiplayer_lobby.tscn", get_parent())
	await get_tree().create_timer(1).timeout
	can_select = true

func flash_animation(node: Node) -> void:
	for i in 5:
		node.modulate.a = 0
		await get_tree().create_timer(0.1, false).timeout
		node.modulate.a = 1
		await get_tree().create_timer(0.1, false).timeout
