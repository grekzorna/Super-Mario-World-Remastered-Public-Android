extends Control

var addons := []
static var loaded_addons := []
var selected_index := 0

var addon_nodes := []

const ADDON_CONTAINER = preload("res://Instances/UI/addon_container.tscn")
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	handle_inputs()

func handle_inputs() -> void:
	if Input.is_action_just_pressed("ui_back"):
		TransitionManager.transition_to_menu(("res://Instances/UI/Menus/title_screen.tscn"), self)
