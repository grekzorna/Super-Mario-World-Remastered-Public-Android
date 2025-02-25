extends Control

var selected_index := 0
var selected_option: Control = null
@onready var container: VBoxContainer = $ScrollContainer/Container

@export var options: Array[OptionNode] = []

var selected := true

var highest_value := false
var lowest_value := false

func _process(delta: float) -> void:
	selected_option = options[selected_index]
	for i in options:
		if not selected:
			i.highlighted = false
		else:
			i.highlighted = selected_option == i
	
	highest_value = selected_index == options.size() - 1
	lowest_value = selected_index == 0
	
	visible = selected
	
	if selected:
		if Input.is_action_just_pressed("ui_down") and not highest_value:
			selected_index += 1
			SoundManager.play_ui_sound(SoundManager.select)
			if selected_index > 3:
				$ScrollContainer.scroll_vertical += 16
		elif Input.is_action_just_pressed("ui_up") and not lowest_value:
			if selected_index < 3:
				$ScrollContainer.scroll_vertical -= 16
			selected_index -= 1
			SoundManager.play_ui_sound(SoundManager.select)
	
	selected_index = clamp(selected_index, 0, options.size() - 1)
