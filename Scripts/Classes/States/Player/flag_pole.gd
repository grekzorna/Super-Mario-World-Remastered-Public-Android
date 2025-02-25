extends PlayerState

var can_slide_down := false
var can_land := false

var pole = null

func enter(msg := {}) -> void:
	can_land = true
	pole = msg.get("Pole")
	player.hitbox_area.monitorable = false
	player.hitbox_area.monitoring  = false
	player.direction = 1
	can_slide_down = false
	player.velocity = Vector2.ZERO
	player.current_animation = "YoshiIdle"
	await pole.start_sequence
	can_slide_down = true

func physics_update(delta: float) -> void:
	player.sprite.scale.x = player.direction
	if can_slide_down:
		player.set_collision_layer_value(1, true)
		player.velocity.y = 100
		if player.is_on_floor():
			if can_land:
				can_land = false
				land()

func land() -> void:
	await pole.flag_down
	state_machine.transition_to("LevelFinish")
	player.velocity = Vector2(100, -200)
