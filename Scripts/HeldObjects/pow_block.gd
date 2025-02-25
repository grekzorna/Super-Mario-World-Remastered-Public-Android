extends HeldObject

var can_explode := false
const PHYSICS_COIN = preload("res://Instances/Prefabs/Items/physics_coin.tscn")
var has_picked_up := false

func physics_update(delta: float) -> void:
	if can_explode:
		if is_on_floor() or is_on_wall() or is_on_ceiling():
			explode()
	else:
		can_explode = (abs(velocity.x) > 50 or abs(velocity.y) > 50) and not held and has_picked_up
	if held:
		has_picked_up = true

func explode() -> void:
	SoundManager.play_sfx(SoundManager.bullet, self)
	SoundManager.play_sfx(SoundManager.yoshi_spit, self)
	set_physics_process(false)
	$Animation.play("Explode")
	$Hitbox/Collision.queue_free()


func _on_explode_area_area_entered(area: Area2D) -> void:
	var node = area.owner
	if node is Coin:
		summon_physics_coin(node)
	if node is Enemy:
		node.die()
	if node is Block:
		node.block_hit("Up")

func summon_physics_coin(old_node: Node) -> void:
	var node = PHYSICS_COIN.instantiate()
	node.global_position = old_node.global_position
	node.can_bounce = true
	GameManager.current_level.add_child(node)
	node.velocity.y = 0
	old_node.queue_free()
