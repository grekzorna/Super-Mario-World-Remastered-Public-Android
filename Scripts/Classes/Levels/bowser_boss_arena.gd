extends Level
@onready var fight_music_1: AudioStreamPlayer = $FightMusic1
@onready var fight_music_2: AudioStreamPlayer = $FightMusic2
@onready var fight_music_3: AudioStreamPlayer = $FightMusic3
@onready var intro_music: AudioStreamPlayer = $Intro
@onready var ending_peach_cutscene: Node2D = $EndingPeachCutscene
@onready var level_bg: Node2D = $LevelBG
const BOWSER_FIRE = preload("res://Instances/Prefabs/Projectiles/bowser_fire.tscn")
@onready var bowser_boss: BowserBoss = $BowserBoss

@export var rain_bg: LevelBG = null

func spawn() -> void:
	GameManager.all_players_dead.connect(stop_music)
	if not bowser_boss.seen_intro:
		intro_music.play()
		await get_tree().create_timer(9, false).timeout
	fight_music_1.play()

func _process(delta: float) -> void:
	for i in [intro_music, fight_music_1, fight_music_2, fight_music_3]:
		i.stream_paused = CoopManager.get_first_alive_player() == null

func stop_music() -> void:
	for i in [fight_music_1, fight_music_2, fight_music_3, intro_music]:
		i.stop()

func start_music() -> void:
	match bowser_boss.phase:
		1:
			fight_music_1.play()
		2:
			fight_music_2.play()
		3:
			fight_music_3.play()

func peach_spawn() -> void:
	if is_instance_valid(rain_bg):
		rain_bg.queue_free()
	GameManager.speedrun_timer.stop()
	CoopManager.bubble_fly_away = true
	ending_peach_cutscene.global_position = bowser_boss.global_position + Vector2(0, 48)
	ending_peach_cutscene.spawn()

func summon_flames() -> void:
	await get_tree().create_timer(1, false).timeout
	for i in $FlamePositions.get_children():
		var node = BOWSER_FIRE.instantiate()
		node.global_position = i.global_position
		add_child(node)
		await get_tree().create_timer(0.5, false).timeout
