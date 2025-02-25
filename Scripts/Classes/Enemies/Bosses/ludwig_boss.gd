extends CharacterBody2D
const LUDWIG_FIRE = preload("res://Instances/Prefabs/Projectiles/ludwig_fire.tscn")
var direction := -1
@onready var animations: AnimationPlayer = $Sprite/Animation
@onready var hitbox: Area2D = $Sprite/Hitbox

var health := 3

signal defeated

var can_hurt := true

var player: Player = null

func spawn_fire() -> void:
	var node = LUDWIG_FIRE.instantiate()
	node.global_position = $Sprite/Fire.global_position
	node.direction = direction
	add_sibling(node)
@onready var sprite: VariationSprite = $Sprite

func _process(delta: float) -> void:
	$Sprite.scale.x = -direction
#
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		player = area.owner
		if Vector2.UP.dot($Sprite/Hitbox.global_position.direction_to(player.global_position)) >= 0.25 and player.velocity.y > 0:
			if can_hurt:
				damage()
			elif player.spin_jumping:
				player.spin_bounce_off()
				player.summon_flash_particle()
				SoundManager.play_sfx(SoundManager.stomp, self)
		else:
			player.damage()

func die() -> void:
	SoundManager.play_sfx(SoundManager.boss_defeat, self)
	await get_tree().create_timer(3.5, false).timeout
	defeated.emit()
	CoopManager.boss_defeated("res://Instances/Levels/Cutscenes/Castle4.tscn")

func summon_puff() -> void:
	$Puff.play("default")
	SoundManager.play_sfx("res://Assets/Audio/SFX/boss-poof.wav", self)

func damage() -> void:
	player.bounce_off()
	health -= 1
	SoundManager.play_sfx(SoundManager.stomp, self)
	SoundManager.play_sfx(SoundManager.stun, self)
	if health <= 0:
		hitbox.queue_free()
		$StateMachine.transition_to("Die")
		animations.play("Die")
		await get_tree().create_timer(0.5, false).timeout
		die()
	else:
		$StateMachine.transition_to("Hurt")
