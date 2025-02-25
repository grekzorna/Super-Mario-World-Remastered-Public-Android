extends Enemy

@onready var held_item = preload("res://Instances/Prefabs/HeldObjects/goombud_held.tscn")

@onready var hitbox: Area2D = $Hitbox

var can_hit := true
func spawn() -> void:
	await get_tree().physics_frame
	hitbox.area_entered.connect(check_hit)

func damage() -> void:
	var node = held_item.instantiate()
	node.global_position = global_position - Vector2(0, 2)
	get_parent().call_deferred("add_child", node)
	queue_free()

func _physics_process(_delta: float) -> void:
	sprite.scale.x = -direction
	$LedgeDetectionCast.floor_normal = get_floor_normal()
	$LedgeDetectionCast.direction = direction
	if is_on_wall() or ($LedgeDetectionCast.is_colliding() == false and is_on_floor()):
		direction *= -1
	if is_on_floor():
		velocity.x = 45 * direction
	if global_position.y >= 250:
		queue_free()
	velocity.y += 15
	move_and_slide()
