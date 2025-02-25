extends PowerUpSpriteExtra
@onready var cape_player: AnimationPlayer = $Animations
@onready var cape_tree = $AnimationTree.get("parameters/playback")
@onready var cape_anim_tree: AnimationTree = $AnimationTree

var spinning := false

var cape_velocity := Vector2.ZERO

var back_anims := ["ClimbIdleBack", "ClimbMoveBack", "ClimbPunchBack"]

var front_anims := ["Dead", "FaceForward", "Victory", "YoshiFaceForward", "PBalloon", "PBalloonLow", "ClimbIdleFront",
					"ClimbMoveFront",  "ClimbPunchFront"]

var back_move_anims := ["ClimbMoveBack"]

func _physics_process(delta: float) -> void:
	if display:
		if player.animating:
			cape_velocity = player.animation_velocity
			handle_cape_animations()
		else:
			cape_tree.travel("Move")
			cape_anim_tree.set("parameters/Move/TimeScale/scale", 2)
	else:
		handle_cape_animations()

func handle_cape_animations():
	cape_anim_tree.set("parameters/Move/TimeScale/scale", player.sprite.speed_scale)
	cape_anim_tree.set("parameters/Idle/blend_position", int(player.riding_yoshi))
	cape_anim_tree.set("parameters/Fall/blend_position", int(player.spinning))
	if player.riding_yoshi:
		if player.sprite.animation == "YoshiTurn":
			cape_tree.travel("YoshiTurnAround")
			z_index = -1
			return
	if player.sprite.animation == "Flip":
		cape_tree.travel("Flip")
		return
	if back_anims.has(player.sprite.animation):
		cape_tree
		if back_move_anims.has(player.sprite.animation):
			cape_tree.travel("FaceBackwardsMove")
			cape_anim_tree.set("parameters/FaceBackwardsMove/TimeScale/scale", player.sprite.speed_scale)
		else:
			cape_tree.travel("FaceBackwards")
		z_index = 0
		return
	elif front_anims.has(player.sprite.animation):
		cape_tree.travel("FaceForward")
		z_index = -1
		return
	if player.riding_yoshi:
		z_index = 0
	else:
		z_index = -1
	if (spinning) and cape_velocity.y < 41:
		cape_tree.travel("Spin")
	elif player.is_on_floor():
		if abs(cape_velocity.x) > 10 and not player.sliding:
			cape_tree.travel("Move")
		else:
			cape_tree.travel("Idle")
	else:
		if cape_velocity.y > 0:
			cape_tree.travel("Fall")
		elif (not player.state_machine.state.name == "CapeFly" and player.state_machine.state.name != "Swim" and player.state_machine.state.name != "WallRun"):
			cape_tree.travel("Idle")
		else:
			cape_anim_tree.set("parameters/Move/TimeScale/scale", 2)
			cape_tree.travel("Move")
	position.x = -2 * scale.x
	if cape_player.current_animation == "Spin":
		position.x = 0
