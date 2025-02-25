class_name MechaKoopa
extends Enemy

var held_object = preload("res://Instances/Prefabs/HeldObjects/mecha_koopa_held.tscn")

const BODY = preload("res://Assets/Sprites/Enemys/MechaKoopaParts/Body.png")
const FEET = preload("res://Assets/Sprites/Enemys/MechaKoopaParts/Feet.png")
const HEAD = preload("res://Assets/Sprites/Enemys/MechaKoopaParts/Head.png")
const SCREW = preload("res://Assets/Sprites/Enemys/MechaKoopaParts/Screw.png")
var parts := [HEAD, FEET, SCREW, BODY]

var move_speed := 25

func _physics_process(delta: float) -> void:
	velocity.y += 15
	if is_on_wall():
		direction *= -1
	if is_on_floor():
		velocity.x = move_speed * direction
	sprite.scale.x = -direction
	move_and_slide()
	if global_position.y > 64:
		queue_free()

func damage() -> void:
	summon_held()
	queue_free()

func summon_gib() -> void:
	ParticleManager.summon_four_part(parts, global_position, 32)
	SoundManager.play_sfx(SoundManager.shatter, self)

func die(score := false) -> void:
	killed.emit()
	summon_gib()
	queue_free()

func summon_held() -> void:
	var node = held_object.instantiate()
	node.direction = direction
	node.global_position = global_position
	add_sibling(node)
	queue_free()


func _on_timer_timeout() -> void:
	var target_player: Player = CoopManager.get_closest_player(global_position)
	if target_player.global_position.x > global_position.x:
		direction = 1
	else:
		direction = -1
