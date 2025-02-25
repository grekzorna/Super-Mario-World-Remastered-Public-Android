@icon("res://Assets/Sprites/Editor/Icons/PowerUp.png")
class_name PowerUp
extends CharacterBody2D

@export var power: PlayerPowerUpState = null
@export var static_movement := false
@export var slow_block_emerge := true ## Whether or not the item should slowly rise from a block or not.
@export var item_emerge_velocity := 200

var box: Area2D = null
var can_grab := true

var direction := 1

signal grabbed

func _enter_tree() -> void:
	set_collision_layer_value(1, false)

func _ready() -> void:
	spawn()
	for i in get_children():
		if i is Area2D:
			box = i	
			box.area_entered.connect(hitbox_hit)
			break
	if static_movement:
		set_physics_process(false)
		set_process(false)

func hitbox_hit(area: Area2D) -> void:
	if can_grab == false:
		return
	elif area.get_parent() is Player:
		if area.get_parent().dead:
			return
		grabbed.emit()
		area.get_parent().power_up(power)
		queue_free()



func block_spawn() -> void:
	if slow_block_emerge:
		item_emerge()
	else:
		item_sprout()

func item_emerge() -> void:
	global_position.y -= 2
	z_index = -1
	set_physics_process(false)
	var tween = create_tween()
	can_grab = false
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "global_position", Vector2(global_position.x, global_position.y - 16), 1)
	await get_tree().create_timer(0.25, false).timeout
	can_grab = true
	await get_tree().create_timer(0.75, false).timeout
	set_physics_process(true)
	can_grab = true

func item_sprout() -> void:
	velocity.y = -item_emerge_velocity
	global_position.y -= 8
	can_grab = false
	await get_tree().create_timer(0.25, false).timeout
	can_grab = true

func spawn() -> void:
	pass
