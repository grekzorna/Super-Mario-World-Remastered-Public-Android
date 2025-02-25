extends AnimatableBody2D

@export var direction := 1
@onready var wall_joint: Node2D = $Help/WallJoint
@onready var animation: AnimationPlayer = $Animation
@onready var sprite: Sprite2D = $Help/Sprite

var bouncing := false

var player: Player = null

const low_launch := 200
const med_launch := 250
const high_launch := 300

func _ready() -> void:
	await get_tree().process_frame
	global_position.x += 4 * direction
	$Help.scale.x = direction
	$Collision.scale.x = direction

func _physics_process(delta: float) -> void:
	for i in $Hitbox.get_overlapping_areas():
		if i.owner is Player and not bouncing:
			if i.owner.global_position.y < global_position.y and i.owner.is_on_floor():
				player_interact(i.owner)

func launch_player(height := 0) -> void:
	if player != null:
		player.state_machine.transition_to("Normal")
		SoundManager.play_sfx(SoundManager.spring, self)
		var h_vel = 0.0
		match height:
			2:
				h_vel = high_launch
			1:
				h_vel = med_launch
			0:
				h_vel = low_launch
		if Input.is_action_pressed(CoopManager.get_player_input_str("jump", player.player_id)):
			player.velocity.y = -h_vel * 1.5
		else:
			player.velocity.y = -h_vel


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		player = area.get_parent()
		if player.global_position.y < global_position.y + 2 == false:
			return

func player_interact(player: Player) -> void:
	bouncing = true
	var distance = wall_joint.global_position.distance_to(player.global_position)
	animation.play("RESET")
	if distance > 32:
		animation.play("High")
	elif distance > 16:
		animation.play("Medium")
	else:
		animation.play("Low")
	await animation.animation_finished
	bouncing = false


func _on_hitbox_area_exited(area: Area2D) -> void:
	if area.owner is Player:
		player = null
