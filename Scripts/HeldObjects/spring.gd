extends HeldObject

const launch_height := 450
const low_height := 200


var players := []

@export var bouncing := false
@onready var animation: AnimationPlayer = $Animation

var spinning := false

func launch_player() -> void:
	for player in players:
		if is_instance_valid(player) and player.carried == false:
			player.state_machine.transition_to("Normal")
			
			if Input.is_action_pressed(CoopManager.get_player_input_str("jump", player.player_id)) or Input.is_action_pressed(CoopManager.get_player_input_str("spin_jump", player.player_id)):
				SoundManager.play_sfx(SoundManager.spring, self, 1.1)
				player.velocity.y = -launch_height
			else:
				SoundManager.play_sfx(SoundManager.spring, self)
				player.velocity.y = -low_height
			player.spin_jumping = Input.is_action_pressed(CoopManager.get_player_input_str("spin_jump", player.player_id))
			player.crouching = false
	players.clear()

func _on_activation_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		if area.get_parent().global_position.y < $ActivationHitbox.global_position.y == false:
			return
		player = area.get_parent() as Player
		if not held:
			player.global_position.y = global_position.y - 16
			player.gravity = player.fall_gravity
			animation.play("Bounce")
			player.current_animation = ("Idle")
			player.jump_queued = false
			player.state_machine.transition_to("Freeze")
			players.append(player)


func _on_hitbox_area_entered(area: Area2D) -> void:
	if not bouncing:
		hitbox_hit(area)


func _on_activation_hitbox_area_exited(area: Area2D) -> void:
	if area.owner is Player:
		if player.state_machine.state.name == "Freeze":
			player.state_machine.transition_to("Normal")
		if players.has(area.owner):
			players.erase(area.owner)
