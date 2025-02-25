extends PowerUp

@export var can_move := true

var idx := 0

var powers := [preload("res://Resources/PlayerPowerUpState/Big.tres"), preload("res://Resources/PlayerPowerUpState/Fire.tres"), preload("res://Resources/PlayerPowerUpState/Cape.tres"), null]

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	$Sprite.play(str(idx))
	if can_move:
		velocity.y += 10
		if is_on_floor():
			velocity.y = -300
		if is_on_wall():
			direction *= -1
		velocity.x = 40 * direction
		move_and_slide()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		var player: Player = area.owner
		if idx == 3:
			player.super_star()
		else:
			player.power_up(powers[idx])
		queue_free()


func _on_timer_timeout() -> void:
	idx += 1
	idx = wrap(idx, 0, 4)
