class_name BrickBlock
extends Block
@onready var sprite: AnimatedSprite2D = $Sprite

const COIN = ("res://Instances/Prefabs/Items/coin.tscn")
var spinning := false
var hit := false
const BRICK_BREAK = preload("res://Assets/Sprites/Particles/BrickBreak.png")
func spawn() -> void:
	ground_pounded.connect(shatter)
	p_switch = item == null

func launch_player() -> void:
	pass

func shatter() -> void:
	SoundManager.play_sfx(SoundManager.shatter, self)
	ParticleManager.summon_four_part([BRICK_BREAK, BRICK_BREAK, BRICK_BREAK, BRICK_BREAK], global_position, 8)
	queue_free()


func block_hit_override(direction := "Up") -> void:
	if can_hit == false:
		return
	if item:
		if item.resource_path == COIN:
			dispense_coin()
			coin_amount -= 1
			GameManager.coins += 1
			GameManager.score += 100
			if coin_amount <= 0:
				can_hit = false
				empty_block()
		else:
			SoundManager.play_sfx(SoundManager.item_sprout, self)
			dispense_item(item)
			can_hit = false
			empty_block()
	else:
		if player.power_state.hitbox_size == "Regular":
			can_hit = false
		for i in 4:
			await get_tree().physics_frame
		if player.power_state.hitbox_size == "Regular":
			shatter()
	await get_tree().create_timer(0.25, false).timeout
	can_hit = true

func die() -> void:
	shatter
