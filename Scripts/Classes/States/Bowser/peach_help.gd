extends BowserBossState
@onready var animations: AnimationPlayer = $"../../Visuals/Peach/Animations"

const MUSHROOM_SCENE = preload("res://Instances/Prefabs/Items/mushroom_item.tscn")
func enter(_msg := {}) -> void:
	boss.cutscene = true
	boss.can_hurt = false
	animations.play("Help")
	await get_tree().create_timer(1, false).timeout
	summon_mushroom()
	await animations.animation_finished
	boss.get_parent().start_music()
	boss.bowser_sprite.play("Enter")
	await boss.bowser_sprite.animation_finished
	boss.return_to_attack()

func summon_mushroom() -> void:
	SoundManager.play_sfx(SoundManager.magic, boss)
	for i in CoopManager.active_players.values():
		var throw_direction := 1
		if boss.global_position > i.global_position:
			throw_direction = -1
		var node = MUSHROOM_SCENE.instantiate()
		node.velocity.y = -100
		node.velocity.x = 100 * throw_direction
		node.global_position = boss.global_position - Vector2(0, 64)
		node.direction = throw_direction
		add_sibling(node)
		await get_tree().create_timer(0.5, false).timeout
