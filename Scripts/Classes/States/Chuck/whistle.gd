extends ChuckState
@onready var whistle_alert_box: Area2D = $"../../WhistleAlertBox"

var can_alert := true
const RED_FLYING_KOOPA = preload("res://Instances/Prefabs/Enemies/red_flying_koopa.tscn")
func enter(_msg := {}) -> void:
	chuck.animations.play("Idle")
	await chuck.player_entered_split
	whistle()

func whistle() -> void:
	SoundManager.play_sfx("res://Assets/Audio/SFX/whistle.wav", chuck)
	chuck.animations.play("Whistle")
	await get_tree().create_timer(0.5, false).timeout
	if chuck.whistle_summon:
		spawn_koopas()
	else:
		alert_enemies()
	await get_tree().create_timer(1, false).timeout
	chuck.animations.play("ClapCharge")

func alert_enemies() -> void:
	for i in whistle_alert_box.get_overlapping_areas():
		if is_instance_valid(i):
			if i.owner is RipVanFish:
				i.owner.alert()

func spawn_koopas() -> void:
	for i in [1, -1]:
		var node = RED_FLYING_KOOPA.instantiate()
		node.direction = -i
		node.global_position = get_viewport().get_camera_2d().get_screen_center_position() + Vector2(i * 240, -24)
		GameManager.current_level.add_child(node)
		print(node)
	
