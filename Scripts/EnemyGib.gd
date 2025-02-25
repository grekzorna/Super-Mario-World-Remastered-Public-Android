class_name EnemyGib
extends CharacterBody2D

var direction := 1

@export_enum("Spin", "Drop", "Poof") var type := 0

var sprite: Node2D = null

func _ready() -> void:
	randomize()
	direction = [-1, 1].pick_random()
	if type == 2:
		ParticleManager.summon_particle(ParticleManager.PUFF, global_position - Vector2(0, 8))
		queue_free()
		return
	if sprite != null:
		add_child(sprite)
		if sprite is AnimatedSprite2D:
			sprite.play()
		elif sprite.get_child(0) is AnimationPlayer:
			sprite.get_child(0).stop()
		sprite.position = Vector2.ZERO
	if type == 0:
		velocity.x = randi_range(-250, 250)
		velocity.y = -250
	else:
		sprite.scale.y = -1
	await get_tree().create_timer(2, false).timeout
	queue_free()

func _physics_process(_delta: float) -> void:
	velocity.y += 15
	if type == 0:
		rotation_degrees += 15 * direction
	move_and_slide()
