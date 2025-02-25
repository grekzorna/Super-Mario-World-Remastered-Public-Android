extends RailFollower

@export var player_activated := false
@onready var motor: VariationAnimatedSprite = $Motor

func _ready() -> void:
	motor.speed_scale = 0
	if player_activated:
		set_physics_process(false)
		set_process(false)

func activate() -> void:
	motor.speed_scale = 1
	set_physics_process(true)
	set_process(true)

func _on_player_detection_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		if area.get_parent().velocity.y > 0:
			activate()
