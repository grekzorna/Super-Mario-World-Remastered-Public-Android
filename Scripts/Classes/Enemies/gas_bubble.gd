extends Enemy

var wave_amount := 0.0

var wave_speed := 0.25

var move_speed := 80

@onready var starting_y := global_position.y

var wave_freq := 64

func _physics_process(delta: float) -> void:
	wave_amount += wave_speed * delta
	wave_amount = wrap(wave_amount, 0, PI * 2)
	global_position.y = starting_y + sin(wave_amount) * wave_freq
	global_position.x -= move_speed * delta
