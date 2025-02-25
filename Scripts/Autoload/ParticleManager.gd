extends Node

const GROUND_POUND_IMPACT = preload("res://Instances/Particles/Player/ground_pound_impact.tscn")
const SPIN_IMPACT = preload("res://Instances/Particles/Player/spin_jump_impact.tscn")
const SPARKLE = preload("res://Instances/Particles/Misc/sparkle.tscn")
const BLOCK_BREAK = preload("res://Instances/Particles/Misc/block_break.tscn")
const LAVA_SPLASH = preload("res://Instances/Particles/Misc/lava_splash.tscn")
const WATER_SPLASH = preload("res://Instances/Particles/Misc/water_splash.tscn")
const _4_PART_BREAK_PARTICLE = preload("res://Instances/Parts/4_part_break_particle.tscn")
const PUFF = preload("res://Instances/Particles/Misc/Puff.tscn")
const YOSHI_MOUNT = preload("res://Instances/Particles/Player/yoshi_mount.tscn")

const GLEAM = preload("res://Instances/Particles/Misc/SpriteParticles/gleam.tscn")
const PUFF_SPR = preload("res://Instances/Particles/Misc/SpriteParticles/puff.tscn")

func summon_particle(particle: PackedScene, position := Vector2.ZERO) -> void:
	await get_tree().process_frame
	var node = particle.instantiate()
	if is_instance_valid(GameManager.current_level):
		node.global_position = position
		GameManager.current_level.add_child(node)
	elif is_instance_valid(GameManager.current_map):
		node.global_position = position
		GameManager.current_map.add_child(node)

func summon_four_part(textures = [], position := Vector2.ZERO, texture_size := 16) -> void:
	await get_tree().process_frame
	var node = _4_PART_BREAK_PARTICLE.instantiate()
	node.sprite_size = texture_size
	node.global_position = position
	node.textures = textures
	if is_instance_valid(GameManager.current_level):
		GameManager.current_level.add_child(node)
