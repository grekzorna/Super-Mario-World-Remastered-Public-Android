extends Level

var reznor_amount := 0
signal defeated

@onready var bridge: Node = $Bridge


var all_defeated := false

func spawn() -> void:
	for i in get_children():
		if i is ReznorEnemy:
			reznor_amount += 1
			i.killed.connect(reznor_killed)

func reznor_killed() -> void:
	reznor_amount -= 1
	if reznor_amount <= 0:
		victory()

func victory() -> void:
	all_defeated = true
	await get_tree().create_timer(1, false).timeout
	defeated.emit()
	CoopManager.boss_defeated("", false)

func delete_bridge() -> void:
	for i in bridge.get_children():
		if i is StaticBody2D:
			ParticleManager.summon_particle(ParticleManager.PUFF_SPR, i.global_position)
			SoundManager.play_sfx(SoundManager.shatter, i)
			i.queue_free()
		elif i is Node2D:
			for x in i.get_children():
				ParticleManager.summon_particle(ParticleManager.PUFF_SPR, x.global_position)
				SoundManager.play_sfx(SoundManager.shatter, x)
				x.queue_free()
		await get_tree().create_timer(1, false).timeout
		if all_defeated:
			return
