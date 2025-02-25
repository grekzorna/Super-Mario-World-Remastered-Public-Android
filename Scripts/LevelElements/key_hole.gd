extends Node2D

@onready var effect: Sprite2D = $Effect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

const key_file_path = ("res://Instances/Prefabs/HeldObjects/key.tscn")

var player: Player = null

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is KeyItem:
		if area.get_parent().held:
			player = area.get_parent().player
			key_exit()
	elif area.get_parent() is Player:
		if area.get_parent().riding_yoshi:
			if area.get_parent().yoshi_stored:
				if area.get_parent().yoshi_stored is KeyItem:
					player = area.get_parent()
					key_exit()
	
func key_exit() -> void:
	GameManager.secret_clear = true
	GameManager.run_states = {}
	GameManager.checkpoint_level = ""
	GameManager.can_pause = false
	GameManager.key_exiting = true
	if SettingsManager.settings_file.timer_type == 1:
		GameManager.speedrun_timer.stop()
	animation_player.play("Grow")
	MusicPlayer.set_music_override(MusicPlayer.SECRET_EXIT, 10)
	get_tree().paused = true
	await animation_player.animation_finished
	GameManager.can_pause = true
	TransitionManager.transition_to_map(GameManager.current_map_path, GameManager.current_level, true, "", false, true)
	GameManager.key_exiting = false

func add_player() -> void:
	pass
