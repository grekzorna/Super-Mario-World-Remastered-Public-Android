extends StaticBody2D
@onready var timer: Timer = $Timer

@export var direction := -1
@export var bullet_time := 2
const BULLET_BILL = preload("res://Instances/Prefabs/Enemies/bullet_bill.tscn")
func _ready() -> void:
	timer.start(bullet_time)
@onready var player_detect: Area2D = $PlayerDetect

func _physics_process(delta: float) -> void:
	var player: Player = CoopManager.get_closest_player(global_position)
	direction = -1 if player.global_position.x < global_position.x else 1

func summon_cannon_ball() -> void:
	if player_detect.get_overlapping_areas().any(func(area: Area2D): return area.owner is Player):
		return
	var node = BULLET_BILL.instantiate()
	node.direction_vector = Vector2.LEFT if direction == -1 else Vector2.RIGHT
	node.global_position = global_position + (node.direction_vector * 8)
	ParticleManager.summon_particle(preload("res://Instances/Particles/Misc/Puff.tscn"), global_position + Vector2(8 * direction, 0))
	GameManager.current_level.add_child(node)
