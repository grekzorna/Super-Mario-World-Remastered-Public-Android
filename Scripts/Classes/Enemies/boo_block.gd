extends Enemy

var target_player: Player = null
@onready var block_collision: CollisionShape2D = $Block/Collision
var collision_active := false
var can_chase := true
var hiding := false
var speed := 50
var player_in_range := false
@onready var animations: AnimationPlayer = $Animations
func _physics_process(delta: float) -> void:
	target_player = CoopManager.get_closest_player(global_position)
	if target_player.global_position.x > global_position.x:
		direction = 1
	else:
		direction = -1
	if can_chase:
		$BooSprite.scale.x = direction
		$BlockSprite.scale.x = direction
		var target_position = (target_player.global_position - Vector2(0, 25)) + Vector2(0, sin(global_position.x) * 32)
		var target_direction = (target_position - global_position).normalized()
		velocity = lerp(velocity, speed * target_direction, delta * 5)
		if target_player.direction != direction:
			can_chase = false
			hiding = true
			animations.play("Hide")

	elif hiding:
		velocity = lerp(velocity, Vector2.ZERO, delta * 30)
		if target_player.direction == direction and not can_chase:
			if player_in_range == false:
				animations.play("Show")
				hiding = false
				await animations.animation_finished
				animations.play("Chase")
				can_chase = true
	move_and_slide()


func _on_block_proximity_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player and area.get_parent() == target_player:
		player_in_range = true


func _on_block_proximity_area_exited(area: Area2D) -> void:
	if area.get_parent() is Player and area.get_parent() == target_player:
		player_in_range = false
