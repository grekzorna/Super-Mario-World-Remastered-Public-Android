extends StaticBody2D

@onready var hitbox: Area2D = $Hitbox

var move := 0.0

@export var sink_rate := 32

var bob_position := 0.0
var sinking := false


@onready var starting_y = global_position.y

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	bob_position = sin(move + global_position.x) * 8
	sinking = hitbox.get_overlapping_areas().any(is_player)
	if sinking:
		player_sink(delta)
	else:
		bob(delta)

func player_sink(delta) -> void:
	global_position.y += sink_rate * delta

func bob(delta) -> void:
	move += delta
	global_position.y = lerpf(global_position.y, bob_position + starting_y, delta * 3)

func is_player(area: Area2D) -> bool:
	return area.get_parent() is Player and area.get_parent().is_on_floor()
