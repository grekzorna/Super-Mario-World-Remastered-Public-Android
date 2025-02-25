extends StaticBody2D
@onready var collision: CollisionShape2D = $Collision
@onready var sprite: Sprite2D = $Sprite
@onready var animation_player: AnimationPlayer = $Sprite/AnimationPlayer

var spinning := false
var hit := false

@export var item: PackedScene = null
@export var coins_amount := 5

func _ready() -> void:
	pass

func spin() -> void:
	return


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		if item == null:
			if area.get_parent().power_state.hitbox_size == "Regular":
				destroy()
		else:
			do_hit()
	if area.get_parent() is HeldObject:
		if area.get_parent().velocity.y != 0:
			if item == null:
				destroy()
			elif hit == false:
				do_hit()


func _on_hitbox_2_area_entered(area: Area2D) -> void:
	if area.get_parent() is HeldObject:
		var object = area.get_parent()
		if object.can_destroy and object.moving:
			if not spinning:
				object.direction *= -1
				do_hit()
	elif area.get_parent() is Player:
		if area.get_parent().attacking:
			await get_tree().process_frame
			do_hit()

func do_hit() -> void:
	animation_player.play("Hit")
	if item != null:
		summon_item()
		hit = true
	else:
		destroy()
	
func destroy() -> void:
	SoundManager.play_sfx(SoundManager.shatter)
	queue_free()


func summon_item() -> void:
	SoundManager.play_sfx(SoundManager.item_sprout)
	var item_node = item.instantiate()
	if item_node is PowerUp:
		item_node.global_position = global_position
		get_parent().add_child(item_node)
		item_node.block_spawn()
	elif item_node is Enemy:
		pass

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		if area.get_parent().spinning and area.get_parent().power_state.hitbox_size != "Small" and item == null and area.get_parent().velocity.y > 0 and not spinning:
			area.get_parent().velocity.y = -200
			area.get_parent().spinning = true#
			SoundManager.play_sfx(SoundManager.shatter)
			queue_free()
		elif area.get_parent().ground_pounding and area.get_parent().power_state.hitbox_size != "Small" and item == null and area.get_parent().velocity.y > 0 and not spinning:
			SoundManager.play_sfx(SoundManager.shatter)
			if area.get_parent().state_machine.state.name == "GroundPound":
				area.get_parent().state_machine.transition_to("GroundPound", {"Instant" = true})
			elif area.get_parent().state_machine.state.name == "PropellerFly":
				area.get_parent().state_machine.transition_to("PropellerFly", {"Instant" = true})
			area.get_parent().velocity.y = 0
			queue_free()
