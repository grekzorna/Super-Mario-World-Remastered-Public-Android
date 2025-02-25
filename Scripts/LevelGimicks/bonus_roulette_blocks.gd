extends Node2D

@onready var blocks := [$Path/Block1/BonusWheelBlock2, $Path/Block2/BonusWheelBlock2, $Path/Block3/BonusWheelBlock2, $Path/Block4/BonusWheelBlock2, $Path/Block5/BonusWheelBlock2, $Path/Block6/BonusWheelBlock2, $Path/Block7/BonusWheelBlock2, $Path/Block8/BonusWheelBlock2, $CenterBlock]
@onready var block_paths: Array[PathFollow2D] = [$Path/Block1, $Path/Block2, $Path/Block3, $Path/Block4, $Path/Block5, $Path/Block6, $Path/Block7, $Path/Block8]
const _1_UP = preload("res://Instances/Prefabs/Items/1_up.tscn")
var speed := 64

var can_move := true

var blocks_hit := 0

var bingos := 0

var block_offset := 0

signal full_bingo


func _ready() -> void:
	GameManager.checkpoint_level = ""
	GameManager.checkpoint_level_name = ""
	GameManager.starting_level_path = owner.scene_file_path
	var index := 0.0
	for i in blocks:
		i.block_hitted.connect(block_hit)
		index = wrap(index, 0, 0.75)
		i.offset = index
		index += 0.5

func _physics_process(delta: float) -> void:
	GameManager.can_pause = false
	if Input.is_action_just_pressed("debug_clear"):
		calculate_bingo()
	if can_move:
		for i in block_paths:
			i.progress += speed * delta

func block_hit() -> void:
	blocks_hit += 1

func check_loop() -> void:
	block_offset = wrap(block_offset + 1, 0, 8)
	if blocks_hit == 8:
		$Timer.queue_free()
		can_move = false
		await get_tree().create_timer(1, false).timeout
		calculate_bingo()
		await get_tree().create_timer(1, false).timeout
		await award_lives()
		end_game()

func end_game() -> void:
	for i in CoopManager.active_players.values():
		i.state_machine.transition_to("Freeze", {"Gravity" = true, "Animating" = true})
		i.yoshi_animations.play("Idle")
		if i.riding_yoshi:
			i.current_animation = "YoshiIdle"
		else:
			i.current_animation = "Idle"
	MusicPlayer.set_music_override(preload("res://Assets/Audio/BGM/SMW/BonusFinish.mp3"))
	await get_tree().create_timer(2.5, false).timeout
	for i in CoopManager.active_players.values():
		if bingos == 0:
			if i.riding_yoshi:
				i.current_animation = "YoshiCrouch"
				i.yoshi_animations.play("Crouch")
			else:
				i.current_animation = "Crouch"
		elif i.riding_yoshi:
			i.current_animation = "YoshiVictory"
		else:
			i.current_animation = "Victory"
	await get_tree().create_timer(2, false).timeout
	TransitionManager.transition_to_map(GameManager.current_map_path, GameManager.current_level, true, "", false, GameManager.secret_clear)

func calculate_bingo() -> void:
	var block_map :=  [0, 1, 2,
					7, 8, 3,
					6, 5, 4]
	
	#Map = [0, 1, 2,
	#		3, 4, 5,
	#		6, 7, 8
	
	var top_bingo = [0, 1, 2]
	var left_bingo = [0, 3, 6]
	var right_bingo = [2, 5, 8]
	var bottom_bingo = [6, 7, 8]
	var mid1_bingo = [3, 4, 5]
	var mid2_bingo = [1, 4, 7]
	var diag1_bingo = [0, 4, 8]
	var diag2_bingo = [6, 4, 2]
	
	var bingo_valids := [false, false, false, false, false, false, false, false]
	
	
	var lines := [$BingoLines/Top, $BingoLines/Left, $BingoLines/Right, $BingoLines/Bottom, $BingoLines/Middle1, $BingoLines/Middle2, $BingoLines/Diag1, $BingoLines/Diag2]
	
	for i in lines:
		i.hide()
	
	var off := 0
	
	var index := 0
	var b_index := 0
	for x in blocks:
		if block_map[b_index] != 8:
			block_map[b_index] = wrap(block_map[b_index] - (block_offset + off), 0, 8)
		b_index += 1
	print([block_offset, off, block_map])
	
	for i in [top_bingo, left_bingo, right_bingo, bottom_bingo, mid1_bingo, mid2_bingo, diag1_bingo, diag2_bingo]:
		var block_1 = blocks[block_map[i[0]]]
		var block_2 = blocks[block_map[i[1]]]
		var block_3 = blocks[block_map[i[2]]]
		
		
		if block_1.wheel_choice == block_2.wheel_choice and block_2.wheel_choice == block_3.wheel_choice:
			bingo_valids[index] = true
			block_1.animations.play("Flash")
			block_2.animations.play("Flash")
			block_3.animations.play("Flash")
			bingos += 1
			lines[index].show()
		index += 1
	if bingos > 0:
		SoundManager.play_global_sfx(SoundManager.correct)
	if bingos == 8:
		full_bingo.emit()

func award_lives() -> void:
	for i in bingos:
		var node = _1_UP.instantiate()
		node.global_position = Vector2(80, -128)
		node.z_index = -2
		GameManager.current_level.add_child(node)
		SoundManager.play_sfx(SoundManager.item_sprout, node)
		await get_tree().create_timer(0.5, false).timeout
	if bingos != 0:
		await get_tree().create_timer(2, false).timeout
