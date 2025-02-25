class_name Door
extends Node2D

@export_file("*.tscn") var level_scene := ""
@export var spawn_position := Vector2.ZERO
var player: Player = null

@export var p_switch := false

var player_in_area := false
var can_enter := true

signal used

func _ready() -> void:
	if p_switch:
		$Sprite.play("pswitch")
		hide()

func _process(delta: float) -> void:
	if is_instance_valid(player):
		if Input.is_action_just_pressed(CoopManager.get_player_input_str("move_up", player.player_id)) and player_in_area and visible:
			if player.is_on_floor() and can_enter:
				get_tree().paused = true
				if p_switch:
					$Sprite.play("pswitchopen")
				else:
					$Sprite.play("open")
				can_enter = false
				SoundManager.play_sfx(SoundManager.door, self)
				used.emit()
				TransitionManager.transition_to_level(level_scene, GameManager.current_level, false, spawn_position if spawn_position != Vector2.ZERO else null, false, "Pixel")

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		player_in_area = true
		player = area.get_parent()

func _on_hitbox_area_exited(area: Area2D) -> void:
	if area.get_parent() is Player:
		player_in_area = false
