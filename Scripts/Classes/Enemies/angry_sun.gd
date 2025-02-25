extends Enemy

@onready var joint: Node2D = $ScreenJoint
@onready var sun: Node2D = $ScreenJoint/SunJoint/Sun
@export var attack_immediately := false

var circle := 0.0

enum States {IDLE, CIRCLING, DIVING}
var state = States.IDLE

var diving := false
var dive := 0.0

func _ready() -> void:
	$ScreenJoint/ColorRect.queue_free()
	if attack_immediately:
		state = States.CIRCLING

func _physics_process(delta: float) -> void:
	match state:
		States.IDLE:
			pass
		States.CIRCLING:
			handle_circling(delta)
		States.DIVING:
			handle_diving(delta)

var dive_distance := 0.0

func _process(delta: float) -> void:
	global_position = get_viewport().get_camera_2d().get_screen_center_position()

func handle_circling(delta: float) -> void:
	$ScreenJoint/SunJoint/Sun/Sprite.play("Idle")
	circle += 12 * delta
	$ScreenJoint/SunJoint.position = lerp($ScreenJoint/SunJoint.position, Vector2(sin(circle) * 12, cos(circle) * 12), delta * 5)

func handle_diving(delta: float) -> void:
	$ScreenJoint/SunJoint/Sun/Sprite.play("Attack")
	$ScreenJoint/SunJoint.position = Vector2.ZERO
	sun.position.x += -180 * direction * delta
	sun.position.y = -88 + (sin(dive) * dive_distance)
	dive += 1.5 * delta
	if dive >= PI:
		direction *= -1
		state = States.CIRCLING
		dive = 0
		$ScreenJoint/SunJoint/Sun/Timer.start()

func begin_attacking() -> void:
	state = States.CIRCLING

func start_dive() -> void:
	var target_player = CoopManager.get_closest_player(global_position)
	dive_distance = (Vector2(0, -88)).distance_to(Vector2(0, self.to_local(target_player.global_position).y))
	print(dive_distance)
	state = States.DIVING
