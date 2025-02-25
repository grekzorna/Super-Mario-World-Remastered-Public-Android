extends SubViewportContainer
@onready var camera: Camera2D = $"../Camera"


func _ready() -> void:
	GameManager.renderer = self
	position = -size / 2

