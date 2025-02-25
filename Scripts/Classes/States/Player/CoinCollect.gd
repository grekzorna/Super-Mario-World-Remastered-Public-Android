extends PlayerState

var coin: Node2D = null

var move := true
var location 

func enter(msg := {}) -> void:
	move = true
	camera_zoom_in_tween(1.25)
	GameManager.player.hud.crystal_coin_anim.play("Appear")
	GameManager.player.hud.main_hud.hide()
	player.sprite_speed_scale = 1
	
	coin = msg.get("Coin")
	location = coin.teleport_location
	player.current_animation = "Spin"
	player.velocity = Vector2.ZERO
	await get_tree().create_timer(1.75).timeout
	move = false
	player.current_animation = "Victory"
	await get_tree().create_timer(1).timeout
	if coin.teleport:
		await return_teleport()
		await get_tree().create_timer(1).timeout
	return_normal()

func return_teleport() -> void:
	SoundManager.play_sfx(SoundManager.teleport, player)
	GameManager.player.hud.crystal_coin_anim.play("Fade")
	await get_tree().create_timer(1).timeout
	player.global_position = location

func return_normal() -> void:
	GameManager.player.hud.crystal_coin_anim.play_backwards("Appear_2")
	state_machine.transition_to("Normal")
	GameManager.player.hud.main_hud.show()
	camera_zoom_in_tween(1)

func camera_zoom_in_tween(zoom_level) -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(player.camera, "zoom", Vector2(zoom_level, zoom_level), 0.5)

func help() -> void:
	var tween_2 = create_tween()
	tween_2.set_trans(Tween.TRANS_CUBIC)
	tween_2.tween_property(player.camera, "position", Vector2(player.camera.position.x, player.camera.to_local(player.global_position).y - 96), 0.5)
func physics_update(delta: float) -> void:
	if move:
		player.global_position = lerp(player.global_position, coin.global_position, delta * 5)
