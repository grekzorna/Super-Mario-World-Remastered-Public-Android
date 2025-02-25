class_name BobOmb
extends Enemy
@export_file(".tscn") var held_scene := ""
const EXPLOSION = ("res://Instances/Prefabs/Interactables/explosion.tscn")
var can_hit := true
@onready var hitbox: Area2D = $Hitbox

func spawn() -> void:
	await get_tree().physics_frame
	hitbox.area_entered.connect(check_hit)

func damage() -> void:
	SoundManager.play_sfx(SoundManager.kick, self)
	var node = load(held_scene).instantiate()
	node.global_position = global_position - Vector2(0, 4)
	get_parent().call_deferred("add_child", node)
	node.velocity = Vector2(0, -100)
	queue_free()

func _physics_process(_delta: float) -> void:
	sprite.scale.x = -direction
	if is_on_floor():
		velocity.x = 45 * direction
	if is_on_wall() && can_hit:
		can_hit = false
		direction *= -1
		await get_tree().create_timer(0.1, false).timeout
		can_hit = true
	if global_position.y >= 250:
		queue_free()
	velocity.y += 15
	move_and_slide()

func explode() -> void:
	await get_tree().create_timer(0.5, false).timeout
	var node = load(EXPLOSION).instantiate()
	node.global_position = global_position
	GameManager.current_level.add_child(node)
	queue_free()


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Fireball:
		damage()
	if area.get_parent() is Explosion:
		explode()
