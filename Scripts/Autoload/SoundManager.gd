extends Node

var bump = ("res://Assets/Audio/SFX/bump.wav")
var coin = ("res://Assets/Audio/SFX/coin.wav")
var fireball = ("res://Assets/Audio/SFX/fireball.wav")
var item_get = ("res://Assets/Audio/SFX/item-get.wav")
var small_jump = ("res://Assets/Audio/SFX/small_jump.wav")
var big_jump = ("res://Assets/Audio/SFX/big_jump.wav")
var kick = ("res://Assets/Audio/SFX/kick.wav")
var pipe = ("res://Assets/Audio/SFX/pipe.wav")
var powerup = ("res://Assets/Audio/SFX/powerup.wav")
var spin = ("res://Assets/Audio/SFX/spin.wav")
var item_sprout = ("res://Assets/Audio/SFX/sprout-item.wav")
var starman_low = ("res://Assets/Audio/SFX/starman-low.wav")
var super_stomp = ("res://Assets/Audio/SFX/super-stomp.wav")
var yoshi_mount = ("res://Assets/Audio/SFX/yoshi-mount.wav")
var yoshi_eat = ("res://Assets/Audio/SFX/yoshi-eat.wav")
var yoshi_gulp = ("res://Assets/Audio/SFX/yoshi-gulp.wav")
var yoshi_spit = ("res://Assets/Audio/SFX/yoshi-spit.wav")
var yoshi_hurt = ("res://Assets/Audio/SFX/yoshi-escape.wav")
var yoshi_hatch = ("res://Assets/Audio/SFX/yoshi-hatch.wav")
var shatter = ("res://Assets/Audio/SFX/shatter.wav")
var reserve_item = ("res://Assets/Audio/SFX/reserved-item.wav")
var vine_grow = ("res://Assets/Audio/SFX/sprout-vine.wav")
var cape_get = ("res://Assets/Audio/SFX/cape-acquire.wav")
var cape_fly = ("res://Assets/Audio/SFX/cape-fly.wav")
var fire_breath = ("res://Assets/Audio/SFX/firebreath.wav")
var bullet = ("res://Assets/Audio/SFX/bullet.wav")
var swim = ("res://Assets/Audio/SFX/swim.wav")
var coin_special = ("res://Assets/Audio/SFX/coin-special.wav")
var menu = ("res://Assets/Audio/SFX/map-spot.wav")
var spring = ("res://Assets/Audio/SFX/spring.wav")
var clap = ("res://Assets/Audio/SFX/clap.wav")
var stun = ("res://Assets/Audio/SFX/stun.wav")
var one_up = ("res://Assets/Audio/SFX/1up.wav")
var checkpoint = ("res://Assets/Audio/SFX/checkpoint.wav")
var stomp = ("res://Assets/Audio/SFX/stomp.wav")
var message = ("res://Assets/Audio/SFX/message.wav")
var switch_activate = ("res://Assets/Audio/SFX/switch.wav")
var select = ("res://Assets/Audio/SFX/map-spot.wav")
var hurry_up = ("res://Assets/Audio/SFX/hurry-up.wav")
var correct = ("res://Assets/Audio/SFX/correct.wav")
var door = ("res://Assets/Audio/SFX/door.wav")
var boss_burn = ("res://Assets/Audio/SFX/boss-burnt.wav")
var boss_flame = ("res://Assets/Audio/SFX/boss-flame.wav")
var map_unlock = ("res://Assets/Audio/SFX/map-unlock.wav")
var map_castle_destroy = ("res://Assets/Audio/SFX/map-castle-demolish.wav")
var thunder = ("res://Assets/Audio/SFX/thunder.wav")
var combos = [("res://Assets/Audio/SFX/kick1.wav"), ("res://Assets/Audio/SFX/kick2.wav"), ("res://Assets/Audio/SFX/kick3.wav"), ("res://Assets/Audio/SFX/kick4.wav"), ("res://Assets/Audio/SFX/kick5.wav"), ("res://Assets/Audio/SFX/kick6.wav"), ("res://Assets/Audio/SFX/kick7.wav"), ("res://Assets/Audio/SFX/kick8.wav")]
var enter_save = ("res://Assets/Audio/SFX/enter_save.wav")
var balloon = ("res://Assets/Audio/SFX/balloon.wav")
var game_over = ("res://Assets/Audio/BGM/SMW/GameOver.mp3")
var wrong = ("res://Assets/Audio/SFX/wrong.wav")
var bone_crumble = ("res://Assets/Audio/SFX/dry-bones-crumble.wav")
var boss_defeat = ("res://Assets/Audio/SFX/boss-defeat.wav")
var boss_fall = ("res://Assets/Audio/SFX/boss-fall.wav")
var carry_grab = ("res://Assets/Audio/SFX/grab-enemy.wav")
var throw = ("res://Assets/Audio/SFX/throw.wav")
var magic = ("res://Assets/Audio/SFX/magic.wav")
var mega_mushroom = ("res://Assets/Audio/SFX/mega_mushroom.mp3")
var water_splash = ("res://Assets/Audio/SFX/water_splash.ogg")
var jump_charge = ("res://Assets/Audio/SFX/charge-jump.wav")
var red_coin_collect = ("res://Assets/Audio/SFX/Redcoin.wav")
var red_coins_complete = ("res://Assets/Audio/SFX/Allred.wav")
var swooper = "res://Assets/Audio/SFX/swooper.wav"
var map_unlock_loop = "res://Assets/Audio/SFX/map-unlock-loop.wav"

func play_ui_sound(sound, pitch := 1.0) -> void:
	var audio_node = AudioStreamPlayer.new()
	audio_node.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	if sound is String:
		sound = load(sound)
	audio_node.stream = (sound)
	audio_node.bus = "UI"
	get_tree().root.add_child(audio_node)
	audio_node.set_pitch_scale(pitch)
	audio_node.play()
	await audio_node.finished
	audio_node.queue_free()

func play_global_sfx(sound, pitch := 1.0) -> void:
	var audio_node = AudioStreamPlayer.new()
	audio_node.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	if sound is String:
		sound = load(sound)
	audio_node.stream = (sound)
	audio_node.bus = "SFX"
	get_tree().root.add_child(audio_node)
	audio_node.set_pitch_scale(pitch)
	audio_node.play()
	await audio_node.finished
	audio_node.queue_free()
 
func play_sfx(sound, node, pitch := 1.0) -> void:
	var audio_node = AudioStreamPlayer2D.new()
	if CoopManager.splitscreen:
		audio_node = AudioStreamPlayer.new()
	audio_node.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	if sound is String:
		sound = load(sound)
	audio_node.stream = (sound)
	audio_node.bus = "SFX"
	get_tree().root.add_child(audio_node)
	if is_instance_valid(node) and not CoopManager.splitscreen:
		audio_node.global_position = node.global_position
		audio_node.max_distance = 512
	if CoopManager.splitscreen:
		audio_node.volume_db = -10
	audio_node.set_pitch_scale(pitch)
	audio_node.play()
	await audio_node.finished
	audio_node.queue_free()
