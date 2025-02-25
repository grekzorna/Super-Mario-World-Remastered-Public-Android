class_name Pokey
extends Enemy

@onready var top_check: Area2D = $CheckAreas/TopCheck
@onready var bottom_check: Area2D = $CheckAreas/BottomCheck
@onready var body: Sprite2D = $Visuals/Body
@onready var head: Sprite2D = $Visuals/Head
const AUTUMN_POKEY = preload("res://Assets/Sprites/Enemys/AutumnPokey.png")
const POKEY_HEAD = preload("res://Assets/Sprites/Enemys/PokeyHead.png")
const POKEY_BODY = preload("res://Assets/Sprites/Enemys/PokeyBody.png")
var top_part := false
var bottom_part := false
var wave := 0.0

var id := 0

func _physics_process(delta: float) -> void:
	velocity.y += 15
	if GameManager.autumn:
		sprite.texture = AUTUMN_POKEY
	elif top_part:
		sprite.texture = POKEY_HEAD
	elif not is_yoshi_item:
		sprite.texture = POKEY_BODY
	sprite.scale.x = -direction
	if is_on_wall():
		direction *= -1
	if bottom_part and $VisibleOnScreenEnabler2D.is_on_screen():
		if get_floor_normal().x != 0:
			velocity.x = 20 * direction
		else:
			velocity.x = 15 * direction
	else:
		velocity.x = 0
	set_collision_layer_value(15, not is_yoshi_item)
	if is_yoshi_item:
		if is_instance_valid(get_node_or_null("Hitbox")):
			$Hitbox.queue_free()
	do_checks(delta)
	if top_part:
		if not bottom_part:
			handle_visual_wave(delta)
	else:
		handle_visual_wave(delta)
	move_and_slide()

func do_checks(delta) -> void:
	top_part = not top_check.get_overlapping_areas().any(is_pokey) and not is_yoshi_item
	bottom_part = bottom_check.get_overlapping_areas().any(is_pokey) == false
	for i in bottom_check.get_overlapping_areas():
		if i.get_parent() is Pokey:
			global_position = i.global_position - Vector2(0, 16)

func do_wall_check() -> bool:
	for i in top_check.get_overlapping_areas():
		if i.get_parent() is Pokey:
			if i.get_parent().is_on_wall():
				return true
	return false

func _exit_tree() -> void:
	id = 0

func on_freeze() -> void:
	var checks := [top_check, bottom_check]
	for x in checks:
		for i in x.get_overlapping_areas():
			if i.get_parent() is Pokey:
				if i.get_parent().frozen == false:
					i.get_parent().freeze()

func is_pokey(area: Area2D) -> bool:
	return area.get_parent() is Pokey and area.get_parent().id == id

func handle_visual_wave(delta) -> void:
	wave += 4 * delta
	sprite.position.x = sin(wave + (global_position.y / 16))
