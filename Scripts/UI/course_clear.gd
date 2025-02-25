extends Control

@onready var time_left: Label = $Timeleft
@onready var multiplier: Label = $Multiplier
@onready var total: Label = $Total
@onready var bonus_star_label: Label = $BonusStar/StarTotal/BonusStars
@onready var player_name: TextureRect = $PlayerName

@onready var drumroll_start: AudioStreamPlayer = $DrumrollStart
@onready var drumroll_loop: AudioStreamPlayer = $DrumrollLoop
@onready var drumroll_end: AudioStreamPlayer = $DrumrollEnd
@onready var bonus_bit: HBoxContainer = $BonusStar
@onready var circle_animation: AnimationPlayer = $Circle/Animation

@onready var character_titles = [preload("res://Assets/Sprites/Characters/Mario/HUDTitle.png"), preload("res://Assets/Sprites/Characters/Luigi/HUDTitle.png"), preload("res://Assets/Sprites/Characters/Toad/HUDTitle.png"), preload("res://Assets/Sprites/Characters/Toadette/HUDTitle.png")]

signal finished
var bonus_stars := 0
var time_lerp := 0.0
var time_multiplier := 0
var time_result := 0.0
const tally_speed := 10
var secret_exit := false
var final_total := 0.0
var star_total := 0.0
var tallying := false
var starting_score := 0
var starting_star := 0
var cutscene := false
var cutscene_level := ""
var victory := false
var moving_victory := true
var walk_off := false
var bonus := false

func _ready() -> void:
	GameManager.all_players_dead.connect(cancel_finish)

func cancel_finish() -> void:
	$Animation.stop()
	hide()

func finished_animation() -> void:
	drumroll_loop.stop()
	drumroll_loop.playing = false
	finished.emit()

func _physics_process(delta: float) -> void:
	time_left.text = str(time_lerp)
	multiplier.text = str(time_multiplier)
	bonus_star_label.text = str(int(bonus_stars))
	total.text = str(int(time_result))
	player_name.visible = CoopManager.players_connected == 1
	if CoopManager.player_characters[0] != null:
		player_name.texture = CoopManager.player_characters[0].HUDTitle
	if tallying:
		if bonus and GameManager.star_points < star_total:
			bonus_stars -= 20 * delta
			GameManager.star_points += 20 * delta
		elif bonus:
			GameManager.star_points = star_total
		
		time_result -= 10000 * delta
		if time_result > 0:
			GameManager.score += 10000 * delta
		else:
			GameManager.score = final_total
		if (time_result <= 0 and bonus == false) or (bonus_stars <= 0 and bonus and time_result <= 0):
			tallying = false
			stop_drumroll()
			if bonus:
				GameManager.star_points = star_total
			

	bonus_stars = clamp(bonus_stars, 0, 999)
	time_result = clamp(time_result, 0, 99999999)

func calculate_points() -> void:
	bonus = GameManager.star_points_goal > 0
	bonus_stars = GameManager.star_points_goal
	starting_star = GameManager.star_points
	starting_score = GameManager.score
	star_total = bonus_stars + starting_star
	time_lerp = GameManager.time
	time_multiplier = 50
	time_result = (GameManager.time * 50)
	bonus_bit.visible = bonus and bonus_stars > 0
	final_total = time_result + starting_score

func level_finish() -> void:
	CoopManager.bubble_fly_away = true
	GameManager.can_pause = false
	if SettingsManager.settings_file.timer_type == 1:
		GameManager.speedrun_timer.stop()
	if not bonus_bit.visible:
		bonus = false
		bonus_stars = 0
	calculate_points()
	$Animation.play("FinishAnimation")
	MusicPlayer.play_course_clear_fanfare()

func tally_score() -> void:
	tallying = true
	start_drumroll()

func exit_level() -> void:
	GameManager.can_pause = true
	if GameManager.playing_custom_level:
		TransitionManager.transition_to_menu("res://Instances/UI/Menus/custom_level_select.tscn", GameManager.current_level)
		return
	elif check_drag_coins() and SaveManager.current_save.peach_coins_unlocked == false:
		TransitionManager.transition_to_level("res://Instances/Levels/Cutscenes/all_dragon_coins_cutscene.tscn", GameManager.current_level)
		return
	elif GameManager.star_points >= 100:
		GameManager.star_points -= 100
		TransitionManager.transition_to_level("res://Instances/Levels/Bonus/bonus_roulette.tscn", GameManager.current_level)
		return
	if GameManager.current_map_path != "":
		TransitionManager.transition_to_map(GameManager.current_map_path, GameManager.current_level, true, "", false, GameManager.secret_clear)
	else:
		TransitionManager.transition_to_level(GameManager.starting_level_path, GameManager.current_level)

var drag_coins := ["res://Resources/Achievements/Completionist/DragCoins/BVDragCoin.tres", "res://Resources/Achievements/Completionist/DragCoins/CIDragCoin.tres", "res://Resources/Achievements/Completionist/DragCoins/DPDragCoin.tres", "res://Resources/Achievements/Completionist/DragCoins/IFDragCoin.tres", "res://Resources/Achievements/Completionist/DragCoins/SPDragCoin.tres", "res://Resources/Achievements/Completionist/DragCoins/SRDragCoin.tres", "res://Resources/Achievements/Completionist/DragCoins/TBDragCoin.tres", "res://Resources/Achievements/Completionist/DragCoins/VDDragCoin.tres", "res://Resources/Achievements/Completionist/DragCoins/YIDragCoin.tres"]

func check_drag_coins() -> bool:
	for i in drag_coins:
		if SaveManager.current_save.achievements_unlocked.has(i) == false:
			return false
	return true

func start_drumroll() -> void:
	drumroll_start.play()
	await drumroll_start.finished
	drumroll_loop.play()

func stop_drumroll() -> void:
	drumroll_loop.stop()
	drumroll_end.play()
	for i in 10:
		drumroll_loop.stop()
		drumroll_loop.stop()
		await get_tree().physics_frame
