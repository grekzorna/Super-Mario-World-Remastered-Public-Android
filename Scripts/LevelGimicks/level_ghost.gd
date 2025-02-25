extends Node2D
@onready var ghost_line: Line2D = $GhostLine
@onready var mario_ghost: AnimatedSprite2D = $MarioGhost

var ghost_route = []
var route = []
var moving := false
signal ghost_tick

func _ready() -> void:
	ghost_setup()
	GameManager.current_level.stopwatch_start.connect(ghost_travel)

func ghost_setup() -> void:
	ghost_line.clear_points()
	if GameManager.best_current_level_ghost != null:
		route = GameManager.best_current_level_ghost.route
		for i in route:
			ghost_line.add_point(self.to_local(i.properties[0]))
	pass

func _physics_process(delta: float) -> void:
	if moving:
		ghost_update(route[GameManager.ghost_index].properties)
		if get_tree().paused == false:
			GameManager.ghost_index += 1
		if GameManager.ghost_index >= route.size():
			GameManager.ghost_index = 0
			queue_free()
	emit_signal("ghost_tick")

#[global_position, power_state, direction, current_animation, rotation, speed_scale]

func ghost_travel() -> void:
	GameManager.racing_ghost = true
	mario_ghost.show()
	moving = true
	


func ghost_update(ghost_path := []) -> void:
	if ghost_path.is_empty():
		return
	mario_ghost.global_position = ghost_path[0]
	mario_ghost.sprite_frames = ghost_path[1].sprites[0]
	mario_ghost.scale.x = ghost_path[2]
	mario_ghost.play(ghost_path[3])
	mario_ghost.rotation = ghost_path[4]
	mario_ghost.speed_scale = ghost_path[5]
	if GameManager.current_level != null:
		mario_ghost.visible = ghost_path[6] == GameManager.current_level.name
