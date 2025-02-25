class_name LakituCloud
extends Node2D

var player: Player = null
var cloud_meter := 30.0

signal player_entered

func _ready() -> void:
	if SettingsManager.sprite_settings.lakitucloud == 0:
		$Sprite.queue_free()
		$OldCloud.show()
	else:
		$OldCloud.queue_free()

func _physics_process(delta: float) -> void:
	if cloud_meter < 5:
		$Animation.play("Flash")
	if cloud_meter <= 0:
		if is_instance_valid(player):
			player.state_machine.transition_to("Normal")
		queue_free()
	cloud_meter -= 1 * delta

func _on_hitbox_area_entered(area: Area2D) -> void:
	var node = area.get_parent()
	if node is Player:
		if node.state_machine.state.name == "CloudFly" or node.dead:
			return
		player = node
		if node.velocity.y > 0:
			player_entered.emit()
			node.riding_cloud = self
			node.state_machine.transition_to("CloudFly")


func _on_hitbox_area_exited(area: Area2D) -> void:
	if area.get_parent() is Player:
		player = null
