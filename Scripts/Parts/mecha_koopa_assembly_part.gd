extends Node2D


var moving := true

@export var assembly_level := 1

@onready var head: Sprite2D = $Parts/Head
@onready var body: Sprite2D = $Parts/Body
@onready var screw: Sprite2D = $Parts/Screw
@onready var feet: Sprite2D = $Parts/Feet

@onready var level_1_parts = [null, feet.texture, null, null]
@onready var level_2_parts = [null, feet.texture, null, body.texture]
@onready var level_3_parts = [head.texture, feet.texture, screw.texture, body.texture]
@onready var level_4_parts = [null, feet.texture, screw.texture, body.texture]

func _on_hitbox_area_entered(area: Area2D) -> void:
	var node = area.get_parent()
	if node is Player:
		if node.ground_pounding or node.attacking or node.spin_attacking:
			die()
		elif node.velocity.y > 50:
			node.velocity.y = -node.jump_height
			SoundManager.play_sfx(SoundManager.kick, self)
			if Input.is_action_pressed("jump"):
				node.gravity = node.jump_gravity
			die()
	if node is Fireball:
		node.queue_free()
		die()
	if area.name == "Press":
		assembly_level += 1

func _physics_process(delta: float) -> void:
	moving = get_parent().assembly_running
	if moving:
		if get_parent().broken:
			global_position.x -= (64 * 5) * delta
		else:
			global_position.x -= 64 * delta
	body.visible = assembly_level > 1
	head.visible = assembly_level > 2
	screw.visible = assembly_level > 3

func die() -> void:
	var part = []
	match assembly_level:
		1:
			part = level_1_parts
		2:
			part = level_2_parts
		3:
			part = level_3_parts
		4:
			part = level_4_parts
	ParticleManager.summon_four_part(part, global_position - Vector2(0, 16), 16)
	SoundManager.play_sfx(SoundManager.shatter, self)
	queue_free()
