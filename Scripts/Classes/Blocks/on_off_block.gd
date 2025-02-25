extends StaticBody2D

@onready var sprite: Sprite2D = $Sprite

var active := true

@export_enum("Red", "Blue") var colour := 0

func _ready() -> void:
	for i in GameManager.current_level.get_children():
		if i is OnOffSwitch:
			i.changed.connect(switch)
	if colour == 1:
		sprite.frame_coords.x = 1
		active = not active

func switch() -> void:
	active = not active

func _process(delta: float) -> void:
	if active:
		sprite.frame_coords.y = 0
	else:
		sprite.frame_coords.y = 1
	sprite.z_index = int(not sprite.frame_coords.y) - 1
	$Collision.set_deferred("disabled", not active)
