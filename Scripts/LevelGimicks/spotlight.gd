extends Node
@onready var light: PointLight2D = $CanvasLayer/DiscoBall/Light
@onready var disco_ball: AnimatedSprite2D = $CanvasLayer/DiscoBall

var active := false

func _ready() -> void:
	for i in GameManager.current_level.get_children():
		if i is LightSwitch:
			i.activated.connect(activate)

func _process(delta: float) -> void:
	light.visible = active
	if active:
		disco_ball.play("Active")
	else:
		disco_ball.play("Inactive")

func activate() -> void:
	active = !active
