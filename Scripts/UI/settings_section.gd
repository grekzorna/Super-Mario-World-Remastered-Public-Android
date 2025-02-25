class_name SettingsSection
extends ScrollContainer

@export var option_nodes: Array[OptionNode]
@export var title := ""
var selected_index := 0

var selected := true

var options := {}
var sprite_options := {}


func _ready() -> void:
	option_nodes.clear()
	for i in $VBoxContainer.get_children():
		if i is OptionNode:
			option_nodes.append(i)
	spawn()

func spawn() -> void:
	pass

func _physics_process(delta: float) -> void:
	if selected:
		if Input.is_action_just_pressed("move_down_0"):
			selected_index += 1
			if selected_index > 3:
				scroll_vertical += 20
		if Input.is_action_just_pressed("move_up_0"):
			selected_index -= 1
			if selected_index < option_nodes.size() - 3:
				scroll_vertical -= 20
		selected_index = clamp(selected_index, 0, option_nodes.size() -1 )
	for i in option_nodes:
		i.highlighted = option_nodes[selected_index] == i and selected

func get_chosen_options() -> Dictionary:
	options.clear()
	for i in option_nodes:
		if i is SliderOptionNode:
			options[i.settings_value] = i.value
		elif i is SelectableOptionNode:
			options[i.settings_value] = i.get_chosen_val()
	return options

func set_option_node_values() -> void:
	for i in option_nodes:
		if i is SpriteSelectionNode:
			if SettingsManager.sprite_settings.has(i.settings_value):
				print(SettingsManager.sprite_settings[i.settings_value])
				i.selected_index = int(SettingsManager.sprite_settings[i.settings_value])
		elif i is SelectableOptionNode:
			if i.option_value_usage == 0:
				print([i.settings_value, SettingsManager.settings_file[i.settings_value], i.selectable_values.find(SettingsManager.settings_file[i.settings_value])])
				var val_to_find = SettingsManager.settings_file[i.settings_value]
				if i.selectable_values[0] is Vector2:
					if val_to_find is String:
						val_to_find = val_to_find.replace(")", "")
						val_to_find = val_to_find.replace("(", "")
						val_to_find = val_to_find.replace(" ", "")
						val_to_find = val_to_find.split(",")
						val_to_find = Vector2(int(val_to_find[0]), int(val_to_find[1]))
				i.selected_index = i.selectable_values.find(val_to_find)
			else:
				if SettingsManager.settings_file.has(i.settings_value):
					i.selected_index = SettingsManager.settings_file[i.settings_value]
		elif i is SliderOptionNode:
			i.value = SettingsManager.settings_file[i.settings_value]
