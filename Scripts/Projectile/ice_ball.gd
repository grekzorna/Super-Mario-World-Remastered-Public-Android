class_name IceBall
extends CharacterBody2D
@onready var sprite: Sprite2D = $Sprite

const speed := 150
var direction = 1
var player: Player = null
var can_bounce := true

func _ready() -> void:
	sprite.scale.x = -direction
	velocity.y = speed
	velocity.x += speed * direction
	await get_tree().create_timer(5, false).timeout
	queue_free()

func _physics_process(_delta: float) -> void:
	sprite.rotation_degrees += 30 * direction
	if is_on_floor():
		if can_bounce:
			can_bounce = false
			velocity.y = -200
		else:
			SoundManager.play_sfx(SoundManager.bump, self)
			queue_free()
	velocity.y += 10
	velocity.y = clamp(velocity.y, -999, 200)
	if is_on_wall() || abs(velocity.x) < 100:
		SoundManager.play_sfx(SoundManager.bump, self)
		queue_free()
		
	move_and_slide()
	
func _exit_tree() -> void:
	ParticleManager.summon_particle(ParticleManager.PUFF, global_position)

func _on_area_2d_area_entered(area: Area2D) -> void:
	var node = area.get_parent()
	if node is Enemy:
		if node.can_ice_freeze:
			node.freeze()
			queue_free()
	elif node is Player and node != player:
		node.ice_freeze()
		queue_free()
