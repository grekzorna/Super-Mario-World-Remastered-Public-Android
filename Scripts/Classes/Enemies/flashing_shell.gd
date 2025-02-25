class_name FlashingShell
extends Enemy

var player_target: Player = null

var combo := 0
var combo_vals := [100, 200, 400, 800, 1000, 2000, 4000, 8000, 0]

func _ready() -> void:
	if GameManager.autumn:
		$Sprite.texture = preload("res://Assets/Sprites/Enemys/Koopas/Masks/FlashingShell.png")

func _physics_process(delta: float) -> void:
	player_target = CoopManager.get_closest_player(global_position)
	if is_instance_valid(player_target):
		if player_target.global_position.x > global_position.x:
			direction = 1
		else:
			direction = -1
	velocity.y += 15
	velocity.x = lerpf(velocity.x, 150 * direction, delta * 2)
	if is_on_wall():
		velocity.x = 100 * get_wall_normal().x
		SoundManager.play_sfx(SoundManager.bump, self)
	move_and_slide()

func damage() -> void:
	player.play_sfx("stomp")
	player.bounce_point_rel(global_position, false)

func add_combo() -> void:
	SoundManager.play_sfx(SoundManager.kick, self, 1 + (float(combo) / 10))
	if combo >= 8:
		SoundManager.play_global_sfx(SoundManager.one_up)
		GameManager.add_life(1, global_position)
		combo = 0
		return
	else:
		GameManager.add_score(combo_vals[combo], true, global_position)
	combo += 1

func _on_destruction_box_area_entered(area: Area2D) -> void:
	if area.owner is Enemy:
		if area.owner.can_slide_damage:
			area.owner.die()
			add_combo()
	elif area.owner is HeldObject:
		if area.owner.destructable:
			area.owner.die()
			add_combo()
