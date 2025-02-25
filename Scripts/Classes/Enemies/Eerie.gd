extends Enemy

@export var move_speed := 64

@export var wave := false
@export var wave_amount := 32
@export var starting_wave_direction := 0

@onready var starting_position = global_position

var wave_move := 0.0

func _physics_process(delta: float) -> void:
	wave_move = wrap(wave_move, 0, PI * 2)
	if wave:
		wave_move += (4 * starting_wave_direction) * delta
		global_position.y = (starting_position.y + (sin(wave_move) * wave_amount))
	
	global_position.x -= move_speed * delta
