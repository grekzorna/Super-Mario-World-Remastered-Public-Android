class_name BoomerangProjectile
extends CharacterBody2D

var player: Player = null

var returning := false

const move_speed := 300

var direction := 1
@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	velocity.x = move_speed * direction
	await get_tree().create_timer(1.5, false).timeout
	returning = true

func _physics_process(delta: float) -> void:
	sprite.rotation_degrees += 1000 * delta
	if returning:
		global_position = lerp(global_position, player.global_position, delta * 5)
		velocity.x = 0
	else:
		velocity.x -= move_speed * direction * delta
	move_and_slide()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player and returning:
		queue_free()
	if area.get_parent() is Enemy:
		if area.get_parent().can_held_item_damage:
			area.get_parent().die()
