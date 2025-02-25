extends PlayerState
@onready var revive_bubble: Node2D = $"../../ReviveBubble"
@onready var revive_hitbox: Area2D = $"../../ReviveBubble/Hitbox"

var can_boost := true
@onready var bubble_place: RayCast2D = $"../../Raycasts/BubblePlace"

func enter(_msg := {}) -> void:
	player.dead = true
	revive_bubble.show()
	revive_bubble.play("idle")
	CoopManager.alive_players.erase(player.player_id)
	player.velocity = Vector2.ZERO
	if GameManager.vs_mode:
		player.global_position = player.starting_position
		revive()

func physics_update(delta: float) -> void:
	player.set_collision_layer_value(1, false)
	player.set_collision_mask_value(1, false)
	player.current_animation = "ClimbIdleFront"
	if revive_hitbox.get_overlapping_areas().any(func(area: Area2D): return area.get_parent() is Player and area.get_parent() != owner):
		revive()
	var direction = (player.global_position.direction_to(CoopManager.get_closest_player(player.global_position).global_position))
	player.hitbox_area.set_deferred("monitorable", false)
	player.hitbox_area.set_deferred("monitoring", false)
	if CoopManager.bubble_fly_away:
		direction = player.global_position.direction_to(get_viewport().get_camera_2d().get_screen_center_position() - Vector2(0, 600))
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("jump", player.player_id)):
		if CoopManager.bubble_fly_away == false:
			speed_boost()
	player.velocity = lerp(player.velocity, player.global_position.distance_to(CoopManager.get_closest_player(player.global_position).global_position) * direction, delta)

func speed_boost() -> void:
	if can_boost == false:
		return
	else:
		can_boost = false
	SoundManager.play_sfx(SoundManager.spin, player, 0.9)
	var direction = player.global_position.direction_to(CoopManager.get_closest_player(player.global_position).global_position)
	player.velocity = 100 * direction
	revive_bubble.play("default")
	await get_tree().create_timer(0.5).timeout
	revive_bubble.play("idle")
	can_boost = true

func exit() -> void:
	player.disable_damage()
	CoopManager.alive_players[player.player_id] = player
	player.velocity.y = -250
	player.global_position.y -= 2
	player.dead = false
	revive_bubble.hide()
	CoopManager.active_players[player.player_id] = player
	await get_tree().process_frame
	player.hitbox_area.set_deferred("monitorable",true)
	player.hitbox_area.set_deferred("monitoring",true)
	player.set_collision_mask_value(1, true)

func revive() -> void:
	if CoopManager.bubble_fly_away:
		return
	CoopManager.dead_players.erase(player.player_id)
	CoopManager.game_overed_players.erase(player.player_id)
	player.vibrate_controller(1)
	SoundManager.play_sfx(SoundManager.clap, player)
	ParticleManager.summon_particle(preload("res://Instances/Particles/Misc/bubble_burst.tscn"), player.global_position)
	state_machine.transition_to("Normal")
	player.disable_damage()
	if bubble_place.is_colliding():
		player.global_position.y = bubble_place.get_collision_point().y
