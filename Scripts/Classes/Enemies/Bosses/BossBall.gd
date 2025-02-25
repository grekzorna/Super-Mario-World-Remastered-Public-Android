extends CharacterBody2D

var direction := 1
const move_speed = 100
@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	velocity.y += 15
	velocity.x = move_speed * direction
	sprite.rotation_degrees += (move_speed * delta) * direction * 3
	move_and_slide()


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player and is_on_floor():
		area.get_parent().damage()
	elif area.get_parent() is LavaArea:
		queue_free()
