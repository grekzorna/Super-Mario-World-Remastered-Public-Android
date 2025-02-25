class_name Fireball
extends CharacterBody2D
@onready var sprite: AnimatedSprite2D = $Sprite

var player: Player = null

var speed := 200
var direction = 1

func _ready() -> void:
	$FlameEmber.emitting = bool(SettingsManager.sprite_settings.fireball)
	if is_instance_valid(player):
		speed += abs(player.velocity.x / 2)
	sprite.scale.x = -direction
	velocity.y = speed
	await get_tree().create_timer(5, false).timeout
	hit_solid()

func _physics_process(_delta: float) -> void:
	if $FlameEmber.emitting:
		sprite.rotation_degrees += 30 * direction
	velocity.x = speed * direction
	if is_on_floor():
		velocity.y = -175 - (get_floor_normal().x * 16)
	velocity.y += 15
	velocity.y = clamp(velocity.y, -speed, 200)
	if is_on_wall() || abs(velocity.x) < 100:
		hit_solid()
		
	move_and_slide()

func hit_solid() -> void:
	SoundManager.play_sfx(SoundManager.bump, self)
	ParticleManager.summon_particle(ParticleManager.PUFF_SPR, global_position)
	queue_free()

func area_enter(area: Area2D) -> void:
	var node = area.owner
	if node is Enemy:
		if node.can_fire_damage:
			if node.z_index_dependant:
				if node.z_index != z_index:
					return
			node.coin_die()
			SoundManager.play_sfx(player.get_sfx("kick"), self)
			self.queue_free()
		else:
			hit_solid()
