extends Enemy

var hiding := true
var jumping := false
var chasing := false

var can_jump := true

@onready var collision: CollisionShape2D = $Collision
const BLOCK_BREAK = preload("res://Assets/Sprites/Particles/BlockBreak.png")
@export_enum("Wall", "Ground") var burrow_type := "Wall"
@onready var wall_hole_texture = preload("res://Assets/Sprites/Enemys/MontyMoleHole.png")
const acceleration := 1
const jump_height := -250
const move_speed := 120

const gravity := 15

var burrow_animation := ""

func _ready() -> void:
	$Hitbox.area_entered.disconnect(check_hit)
	match burrow_type:
		"Wall":
			burrow_animation = "BurrowSide"
		"Ground":
			burrow_animation = "BurrowTop"

func _physics_process(delta: float) -> void:
	if hiding:
		handle_hiding(delta)
	elif jumping:
		handle_jumping(delta)
	elif chasing:
		handle_chasing(delta)
	sprite.scale.x = -direction
	collision.set_deferred("disabled", hiding)
	move_and_slide()

func _process(delta: float) -> void:
	pass

func handle_chasing(delta: float) -> void:
	player = CoopManager.get_closest_player(global_position)
	velocity.x = lerpf(velocity.x, move_speed * direction, acceleration * delta)
	velocity.y += gravity
	sprite.play("Move")
	if direction == 1:
		if global_position.x > player.global_position.x:
			direction = -1
	elif direction == -1:
		if global_position.x < player.global_position.x:
			direction = 1
	if is_on_wall():
		velocity.x = abs(move_speed / 2) * get_wall_normal().x

func handle_hiding(_delta: float) -> void:
	can_hurt = false
	hide()
	velocity = Vector2.ZERO

func handle_jumping(_delta: float) -> void:
	can_hurt = true
	velocity.y += gravity
	if is_on_floor():
		jumping = false
		chasing = true

func leave_hole() -> void:
	var hole = Sprite2D.new()
	hole.texture = wall_hole_texture
	hole.global_position = global_position - Vector2(0, 8)
	hole.z_index -= 5
	GameManager.current_level.add_child(hole)

func damage() -> void:
	die()

func _on_hiding_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player and can_jump:
		can_jump = false
		player= area.get_parent()
		hiding = false
		show()
		sprite.play(burrow_animation)
		await get_tree().create_timer(1, false).timeout
		$Hitbox.area_entered.connect(check_hit)
		sprite.play("Jump")
		$Hitbox.monitorable = true
		$Hitbox.monitoring = true
		if burrow_type == "Wall":
			ParticleManager.summon_four_part([BLOCK_BREAK, BLOCK_BREAK, BLOCK_BREAK, BLOCK_BREAK], global_position, 8)
			leave_hole()
		else:
			ParticleManager.summon_four_part([BLOCK_BREAK, null, BLOCK_BREAK, null], global_position, 8)
		SoundManager.play_sfx(SoundManager.shatter, self)
		velocity.y = jump_height
		jumping = true
