extends Node2D

var red_coins := []

@onready var power_ups := [preload("res://Resources/PlayerPowerUpState/Big.tres"), preload("res://Resources/PlayerPowerUpState/Fire.tres"),
							preload("res://Resources/PlayerPowerUpState/Cape.tres"), preload("res://Resources/PlayerPowerUpState/Ice.tres"),
							preload("res://Resources/PlayerPowerUpState/Shell.tres")]

signal activated

var coins_collected := 0

func _ready() -> void:
	red_coins = get_red_coins()

func get_red_coins() -> Array:
	var arr := []
	for i in GameManager.current_level.get_children():
		if i is RedCoin:
			arr.append(i)
			i.collected.connect(red_coin_collected)
	return arr

func activate() -> void:
	SoundManager.play_sfx(SoundManager.switch_activate, self)
	MusicPlayer.set_music_override(MusicPlayer.P_SWITCH)
	for i in red_coins:
		i.active = true
	await get_tree().create_timer(10, false).timeout
	coins_finished()

func red_coin_collected() -> void:
	coins_collected += 1
	if coins_collected >= 8:
		coins_collected = 0
		await get_tree().create_timer(1, false).timeout
		coins_finished()

func coins_finished() -> void:
	MusicPlayer.stop_music_override(MusicPlayer.P_SWITCH)
	GameManager.drop_item(power_ups.pick_random())
	for i in red_coins:
		if is_instance_valid(i):
			i.queue_free()
	queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if visible == false:
		return
	if area.get_parent() is Player:
		activate()
		hide()
