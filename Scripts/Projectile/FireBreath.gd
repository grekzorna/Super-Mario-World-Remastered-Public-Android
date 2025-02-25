extends Node2D

@onready var top: AnimatedSprite2D = $Top
@onready var middle: AnimatedSprite2D = $Middle
@onready var bottom: AnimatedSprite2D = $Bottom

@export var parts: Array[Node] = []

const move_speed := 150
var direction := 1


func _ready() -> void:
	await get_tree().physics_frame
	global_position.x += 8 * direction
	SoundManager.play_sfx(SoundManager.fire_breath, self)
	await get_tree().create_timer(10, false).timeout
	for i in parts:
		if is_instance_valid(i):
			ParticleManager.summon_particle(ParticleManager.PUFF_SPR, i.global_position)
	queue_free()


func _physics_process(delta: float) -> void:
	var flame_directions := [Vector2(move_speed * direction, -float(move_speed) / 4), Vector2(((move_speed * direction) * 1.1), 0), Vector2(move_speed * direction, float(move_speed) / 4)]
	var index := 0
	if parts.size() > 1:
		for i in parts:
			if is_instance_valid(i):
				i.scale.x = direction
				i.global_position += flame_directions[index] * delta
			index += 1
	else:
		if is_instance_valid(parts[0]):
			parts[0].scale.x = direction
			parts[0].global_position += flame_directions[1] * delta

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Enemy:
		if area.get_parent().can_fire_damage:
			SoundManager.play_sfx(SoundManager.kick, area)
			area.get_parent().coin_die()
	if area.get_parent() is HeldObject:
		if area.get_parent().destructable:
			SoundManager.play_sfx(SoundManager.kick, area)
			area.get_parent().die()
