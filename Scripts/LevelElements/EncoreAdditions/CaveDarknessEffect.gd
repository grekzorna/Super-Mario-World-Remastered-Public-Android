extends Node
@onready var dark_overlay: Sprite2D = $DarkOverlay

func _enter_tree() -> void:
	GameManager.darkness = true

func _ready() -> void:
	if GameManager.encore_mode == false:
		queue_free()
		return

func _exit_tree() -> void:
	GameManager.darkness = false
