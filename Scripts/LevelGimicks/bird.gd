extends CharacterBody2D

var can_fly := true
var direction := 1

var can_hop := true

static var colour := 0

func _ready() -> void:
	colour = randi_range(0, 4)
	colour += 1
	colour = wrap(colour, 0, 4)
	$Sprite.frame_coords.y = colour
	walk_around()

func walk_around() -> void:
	can_hop = true
	await get_tree().create_timer(1, false).timeout
	can_hop = false
	await get_tree().create_timer(2 + randf_range(0, 2)).timeout
	if randi_range(0, 1) == 0:
		direction *= -1
	walk_around()
	

func _physics_process(delta: float) -> void:
	if can_fly == true:
		velocity.y += 15
		if is_on_floor() and can_hop:
			velocity.y = -100
	$Sprite.scale.x = -direction
	if is_on_floor():
		velocity.x = 0
	elif can_hop:
		velocity.x = 50 * direction
	move_and_slide()


func fly_tween() -> void:
	if can_fly:
		can_fly = false
	else:
		return
	SoundManager.play_sfx(SoundManager.swooper, self)
	$Animation.play("Fly")
	var fly_position = global_position - Vector2(64 * direction, 256)
	var tween = create_tween()
	tween.tween_property(self, "global_position", fly_position, 1)
	await tween.finished
	queue_free()

func _on_player_detect_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		fly_tween()
