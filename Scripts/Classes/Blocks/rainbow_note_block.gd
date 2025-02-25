extends Node2D
@onready var block: StaticBody2D = $Block

@onready var sprite: Sprite2D = $Block/Sprite

func _ready() -> void: 
	update_block()

func update_block() -> void:
	var sprite_frame := 0
	for i in (global_position.x / 16):
		sprite_frame += 1
		if sprite_frame > 3:
			sprite_frame = 0
	sprite.frame = sprite_frame

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"): 
		update_block()

func animate_reset() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(block, "position", Vector2(0, 0), 0.25)

func block_activated() -> void:
	block.position.y = 4

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is PhysicsBody2D:
		block_activated()



func _on_hitbox_area_exited(area: Area2D) -> void:
	if area.get_parent() is PhysicsBody2D:
		animate_reset()
