extends Level
@onready var intro_animation: AnimationPlayer = $IntroAnimation

const CASTLE_2 = ("res://Instances/Levels/Cutscenes/Castle2.tscn")
const CASTLE_5 = ("res://Instances/Levels/Cutscenes/Castle5.tscn")
func spawn() -> void:
	for i in 10:
		await get_tree().physics_frame
	get_tree().paused = true
	await intro_animation.animation_finished
	get_tree().paused = false

func move_walls() -> void:
	wall_tween($WallL, 1)
	wall_tween($WallR, -1)
func wall_tween(node, direction := 1) -> void:
	var tween = create_tween()
	tween.tween_property(node, "position:x", node.position.x + 12 * direction, 0.5)

func victory() -> void:
	if name == "MortonBossRoom":
		CoopManager.boss_defeated(CASTLE_2)
	else:
		CoopManager.boss_defeated(CASTLE_5)
