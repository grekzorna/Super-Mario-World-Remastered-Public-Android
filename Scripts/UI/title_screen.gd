extends Control

func open_settings() -> void:
	TransitionManager.transition_to_menu("res://Instances/UI/Menus/settings_menu.tscn", self)

func open_online_menu() -> void:
	TransitionManager.transition_to_menu("res://Instances/Levels/multiplayer_lobby.tscn", self)

func open_addon_menu() -> void:
	TransitionManager.transition_to_menu("res://Instances/UI/Menus/custom_level_select.tscn", self)

func open_custom_levels() -> void:
	TransitionManager.transition_to_menu("res://Instances/UI/Menus/custom_level_select.tscn", self)

func quit_game() -> void:
	get_tree().quit()

func _ready() -> void:
	SaveManager.current_save = {}
