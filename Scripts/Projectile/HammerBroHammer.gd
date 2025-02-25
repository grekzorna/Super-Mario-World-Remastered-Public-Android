extends Enemy

@onready var animation: AnimationPlayer = $Sprite/Animation

@export var can_damage_enemies := false

func _ready() -> void:
	velocity.x = 35 * direction
	velocity.y = -200
	animation.speed_scale = 3 * direction
	sprite.flip_h = direction == -1
	await get_tree().create_timer(1, false).timeout
	can_damage = true

func _physics_process(delta: float) -> void:
	velocity.x = 35 * direction
	velocity.y += 5
	if global_position.y > 200:
		queue_free()
	move_and_slide()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player and not can_damage_enemies:
		if can_damage:
			area.get_parent().damage()
	if area.owner is Enemy and can_damage_enemies:
		if area.owner.can_held_item_damage:
			area.owner.die()
