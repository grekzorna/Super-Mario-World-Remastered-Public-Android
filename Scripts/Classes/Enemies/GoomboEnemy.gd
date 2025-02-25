extends Enemy
@onready var held_item = preload("res://Instances/Parts/galoomba_held.tscn")

@export var winged := false
@onready var wings: AnimatedSprite2D = $Sprite/Wings
@onready var hitbox: Area2D = $Hitbox
@onready var autumn_sprite: AnimatedSprite2D = $AutumnSprite
@onready var autumn_wings: AnimatedSprite2D = $AutumnSprite/Wings

var can_hit := true

var can_bounce := true

var bounce_count := 0

func spawn() -> void:
	await get_tree().physics_frame
	hitbox.area_entered.connect(check_hit)
	autumn_sprite.visible = GameManager.autumn
	if GameManager.autumn:
		sprite.hide()
		sprite = autumn_sprite
		wings = autumn_wings

func damage() -> void:
	if winged:
		winged = false
		return
	var node = held_item.instantiate()
	node.global_position = global_position - Vector2(0, 2)
	node.direction = direction
	get_parent().call_deferred("add_child", node)
	queue_free()

func _physics_process(_delta: float) -> void:
	sprite.scale.x = -direction
	wings.visible = winged
	if is_on_floor() and not winged:
		velocity.x = 45 * direction
	elif winged:
		velocity.x = 45 * direction
	if is_on_wall() && can_hit:
		can_hit = false
		direction *= -1
		await get_tree().create_timer(0.1, false).timeout
		can_hit = true
	if winged:
		if is_on_floor():
			if can_bounce:
				bounce_count += 1
				if bounce_count >= 3:
					velocity.y = -300
					can_bounce = false
					bounce_count = 0
					await get_tree().create_timer(2, false).timeout
					can_bounce = true
				else:
					velocity.y = -200
					
	if global_position.y >= 250:
		queue_free()
	velocity.y += 15
	move_and_slide()
