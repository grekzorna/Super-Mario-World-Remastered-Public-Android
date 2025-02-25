extends Node2D

@onready var skulls = [$Raft1, $Raft2, $Raft3, $Raft4]

const gravity := 15
const max_fall_speed := 100
const move_speed := 50

var moving := false

func _physics_process(delta: float) -> void:
	for i in skulls:
		if moving:
			i.get_node("Sprite").play("Moving")
			i.velocity.y += gravity
			i.velocity.y = clamp(i.velocity.y, -9999, max_fall_speed)
			i.velocity.x = move_speed
		else:
			i.velocity = Vector2.ZERO
		i.move_and_slide()


func _on_activation_area_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		var player = area.get_parent()
		if player.velocity.y > 0:
			moving = true
