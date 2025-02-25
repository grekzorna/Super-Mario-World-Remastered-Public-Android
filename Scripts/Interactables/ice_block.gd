class_name IceBlock
extends CarryItem

@export var size := Vector2.ONE

@onready var collisions = [$SmallCollision, $MediumCollision, $LargeCollision]
@onready var hitbox: Area2D = $Hitbox
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D

var crack_prog := 0
@onready var crack_sprite: Sprite2D = $Crack

var crack_limit := 20
var shaking := false
@onready var visuals: NinePatchRect = $Visuals

@export var frozen_target: Node2D = null
const ICE_BREAK = preload("res://Assets/Sprites/Particles/IceBreak.png")

func _ready() -> void:
	can_fall = false
	visuals.size = size * 16
	visuals.position = Vector2(-((visuals.size.x) / 2), -(visuals.size.y))
	var shape = RectangleShape2D.new()
	shape.size = visuals.size
	collision.shape = shape
	collision.position.y = -(shape.size.y / 2)
	hitbox.add_child(collision.duplicate())
	await get_tree().create_timer(1, false).timeout
	can_fall = true

func physics_update(delta: float) -> void:
	velocity_lerp = lerp(velocity_lerp, velocity, delta * 20)
	if $WaterBouyancy.is_in_water():
		can_fall = false
		velocity.y = lerpf(velocity.y, -70, delta * 5)
	if is_on_floor() and not thrown:
		if velocity_lerp.y > 250:
			destroy()
	if is_on_wall():
		if abs(velocity_lerp.x) > 100:
			destroy()
	if is_on_ceiling():
		destroy()
	set_collision_layer_value(1, not moving)

func destroy() -> void:
	SoundManager.play_sfx(SoundManager.shatter, self, 1.5)
	free_target()
	ParticleManager.summon_four_part([ICE_BREAK, ICE_BREAK, ICE_BREAK, ICE_BREAK], global_position - Vector2(0, 8), 8)
	for i in 2:
		await get_tree().physics_frame
	queue_free()

func free_target() -> void:
	if is_instance_valid(frozen_target) == false:
		return
	if frozen_target is Player:
		frozen_target.global_position.y -= 8
		await get_tree().physics_frame
		frozen_target.state_machine.transition_to("Thrown")
		frozen_target.velocity = Vector2(-100 * direction, -200)
	elif frozen_target is Enemy:
		SoundManager.play_sfx(SoundManager.kick, self)
		frozen_target.die()

func _process(delta: float) -> void:
	if is_instance_valid(frozen_target):
		frozen_target.global_position = global_position
		if frozen_target is Enemy:
			frozen_target.set_physics_process(false)
			frozen_target.set_process(false)
			frozen_target.process_mode = Node.PROCESS_MODE_DISABLED
			frozen_target.global_position += frozen_target.ice_offset
		if frozen_target is Player:
			frozen_target.carried = carried
			if Input.is_action_just_pressed(CoopManager.get_player_input_str("jump", frozen_target.player_id)):
				player_crack()
		else:
			frozen_target.set_process(false)
			frozen_target.set_physics_process(false)
		if frozen_target is Enemy:
			if is_instance_valid(frozen_target.sprite):
				if frozen_target.sprite is AnimatedSprite2D:
					frozen_target.sprite.stop()
				else:
					frozen_target.sprite.set_process_mode(PROCESS_MODE_DISABLED)
	crack_sprite.visible = crack_prog > 0
	crack_sprite.frame = int(crack_prog / (crack_limit / 3))
	if global_position.y > 128:
		queue_free()
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.owner == frozen_target:
		return
	if area.owner == self:
		return
	if area.owner is CarryItem:
		if area.owner.destructable and can_hurt:
			area.owner.destroy()
			destroy()
	var node = area.owner
	if node is Enemy:
		if node.can_slide_damage and can_hurt:
			node.die()
	if node is Player:
		if node.ground_pounding:
			destroy()
		await get_tree().create_timer(0.25, false).timeout
		can_fall = true
	if node is HeldObject:
		if node.destructable:
			node.die()

func player_crack() -> void:
	crack_prog += 1
	shake()
	SoundManager.play_sfx(SoundManager.jump, self)
	SoundManager.play_sfx(SoundManager.bump, self)
	if crack_prog >= crack_limit:
		destroy()
	

func shake() -> void:
	shaking = true
	await get_tree().create_timer(0.2).timeout
	shaking = false


func _on_player_jump_hitbox_area_entered(area: Area2D) -> void:
	var node = area.get_parent()
	if carried or thrown:
		return
	if node is Player:
		if node.velocity.y < 0:
			destroy()
