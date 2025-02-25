extends Node2D


signal block_hit(direction: String)

@onready var hitbox: Area2D = $HurtBox/Hitbox
@onready var shape: CollisionShape2D = $HurtBox/Hitbox/Shape

var top_check_enabled := false

func _process(delta: float) -> void:
	shape.set_deferred("disabled", not top_check_enabled)
	for i in hitbox.get_overlapping_areas():
		check_node(i.get_parent())

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		get_parent().player = area.get_parent()
		if area.get_parent().velocity.y < 100 or area.get_parent().carried:
			hit()
			block_hit.emit("Up")
	elif area.get_parent() is HeldObject:
		if not area.get_parent().held and area.get_parent().velocity.y < 100:
			hit()
			block_hit.emit("Up")

func hit() -> void:
	if get_parent().can_hit:
		top_check_enabled = true
		await get_tree().create_timer(0.2).timeout
		top_check_enabled = false

func check_node(node: Node) -> void:
	if node is Enemy:
		if node.can_slide_damage:
			node.melee_attack()
	if node is PowerUp:
		if node is CharacterBody2D:
			if node.is_physics_processing():
				node.velocity.y = -200
	if node is HeldObject:
		node.velocity.y = -200
