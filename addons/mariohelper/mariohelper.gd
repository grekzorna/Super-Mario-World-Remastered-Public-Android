@tool
extends EditorPlugin

var helper = preload("res://addons/mariohelper/Helper.tscn")
var helper_node
const MOD_PACKER = preload("res://addons/mariohelper/mod_packer.tscn")
func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	helper_node = helper.instantiate()
	add_control_to_bottom_panel(helper_node, "Mario Helper")
	var packer = MOD_PACKER.instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BR, packer)


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_control_from_bottom_panel(helper_node)
	helper_node.free()
