extends Node2D
@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var clouds_fg: Parallax2D = $CloudsFG/ParallaxLayer
@onready var clouds: Parallax2D = $Clouds
@export var show_fg := true
func _ready() -> void:
	await get_tree().physics_frame
	clouds_fg.visible = show_fg
	clouds.autoscroll.x = 32
	clouds_fg.autoscroll.x = 64
