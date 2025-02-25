extends Node

@export var main_boss: CharacterBody2D = null

@export var dummies: Array[Node2D] = []

var pipes: Array[Vector2]

var can_lower := false

var can_hit := false

@export var health := 3

var boss_dead := false


signal defeated

func _ready() -> void:
	get_pipes()
	main_boss.get_node("Sprite/Hitbox").owner = main_boss
	for i in dummies:
		i.get_node("Sprite/Hitbox").owner = i
	await get_tree().create_timer(2, false).timeout
	pick_positions()
	raise_enemies()

func get_pipes() -> void:
	for i in get_parent().get_children():
		if i is Pipe:
			pipes.append(i.global_position)
			print(i)

func raise_enemies() -> void:
	main_boss.can_hurt = true
	main_boss.can_damage = true
	for i in dummies:
		i.can_hurt = false
		i.can_damage = false
	can_hit = true
	can_lower = true
	main_boss.get_node("Animations").play("Raise")
	main_boss.show()
	main_boss.get_node("Sprite").play(str(randi_range(1, 4)))
	for i in dummies:
		i.show()
		i.get_node("Animations").play("Raise")
	await main_boss.get_node("Animations").animation_finished
	main_boss.can_hurt = true
	main_boss.can_damage = true
	for i in dummies:
		i.can_hurt = true
		i.can_damage = true
	await get_tree().create_timer(2, false).timeout
	if can_lower:
		lower_enemies()

func lower_enemies() -> void:
	main_boss.get_node("Animations").play_backwards("Raise")
	for i in dummies:
		i.get_node("Sprite").play("Idle")
		i.get_node("Animations").play_backwards("Raise")
	await get_tree().create_timer(2, false).timeout
	for i in dummies:
		i.hide()
	main_boss.hide()
	if boss_dead:
		return
	pick_positions()
	raise_enemies()

func pick_positions() -> void:
	var pipe_save = pipes.duplicate()
	main_boss.global_position = pipe_save.pop_at(randi_range(0, pipe_save.size() - 1))
	for i in dummies:
		i.global_position = pipe_save.pop_at(randi_range(0, pipe_save.size() - 1))

func enemy_hit(enemy := "") -> void:
	if can_hit:
		can_hit = false
	else:
		return
	can_lower = false
	can_hit = false
	if enemy == main_boss.name:
		await get_tree().create_timer(0.5, false).timeout
		SoundManager.play_ui_sound(SoundManager.correct)
		health -= 1
		for i in dummies:
			i.get_node("Animations").play_backwards("Raise")
		if health <= 0:
			main_boss.boss_die()
			return
	else:
		for i in dummies:
			if i.name != enemy:
				i.get_node("Animations").play_backwards("Raise")
		main_boss.get_node("Animations").play_backwards("Raise")
		await get_tree().create_timer(0.5, false).timeout
		SoundManager.play_ui_sound(SoundManager.wrong)
	await get_tree().create_timer(0.4, false).timeout
	lower_enemies()

func main_hit() -> void:
	pass

func dummy_hit() -> void:
	pass
const CASTLE_2 = ("res://Instances/Levels/Cutscenes/Castle3.tscn")
func victory() -> void:
	defeated.emit()
	if name != "WendyBoss":
		CoopManager.boss_defeated(("res://Instances/Levels/Cutscenes/Castle3.tscn"))
	else:
		CoopManager.boss_defeated(("res://Instances/Levels/Cutscenes/Castle6.tscn"))

func lava_entered() -> void:
	SoundManager.play_sfx(SoundManager.boss_flame, main_boss)
	await get_tree().create_timer(1, false).timeout
	victory()
