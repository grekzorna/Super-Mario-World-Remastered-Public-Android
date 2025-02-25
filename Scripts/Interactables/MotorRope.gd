extends RailFollower
@onready var climbable_area: Climbable = $ClimbableArea

func _ready() -> void:
	set_physics_process(false)
	set_process(false)

func activate() -> void:
	$Motor.play("default")
	$SteamParticles.emitting = true
	set_physics_process(true)
	set_process(true)

func physics_update(delta: float) -> void:
	climbable_area.climbable_velocity = direction_vector * (move_speed)
