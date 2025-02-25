extends Node2D

@export var power_up: PlayerPowerUpState
@onready var _1_up: CharacterBody2D = $"1Up"

var can_pickup := false

var is_one_up := false

var y_vel := -250.0

func _ready() -> void:
	if not is_one_up:
		$Sprite.texture = power_up.item_sprite
		$Sprite.hframes = $Sprite.texture.get_width() / 16
		_1_up.queue_free()
	else:
		_1_up.can_grab = false
		$Sprite.queue_free()
	await get_tree().create_timer(1, false).timeout
	can_pickup = true
	if is_instance_valid(_1_up):
		_1_up.can_grab = true

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.owner is Player and can_pickup:
		area.owner.power_up(power_up)
		queue_free()

func _physics_process(delta: float) -> void:
	y_vel += 5
	global_position.y += y_vel * delta
	global_position.x += 10 * delta
