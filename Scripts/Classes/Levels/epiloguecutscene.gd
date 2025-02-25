extends Node

@onready var players := [$Player1, $Player2, $Player3, $Player4]
@onready var eggs := [$Eggs/Egg1, $Eggs/Egg2, $Eggs/Egg3, $Eggs/Egg4, $Eggs/Egg5, $Eggs/Egg6, $Eggs/Egg7]
const BIG = preload("res://Resources/PlayerPowerUpState/Big.tres")
@onready var yoshis := [$RedYoshi, $YellowYoshi, $BlueYoshi, $GreenYoshi]
var egg_positions := [104, 120, 136, 152, 208, 224, 240]
var player_positions := [168, 224, 128, 104]

var missing_eggs := 0
signal finished

func _ready() -> void:
	set_yoshi_shader_colours($RedYoshi, 1)
	set_yoshi_shader_colours($YellowYoshi, 3)
	set_yoshi_shader_colours($BlueYoshi, 2)
	set_yoshi_shader_colours($GreenYoshi, 0)
	setup_players()
	move_players()
	move_yoshi()
	move_peach()
	move_eggs()
	await get_tree().create_timer(11, false).timeout
	await reveal_eggs()
	if missing_eggs > 3:
		$"../CastRoll/Music".pitch_scale = 0.8
	else:
		celebrate()
	$"../CastRoll/Music".play()
	$ThanksAnimation.play("Enter")
	await get_tree().create_timer(4, false).timeout
	$"../CastRoll/Music".pitch_scale = 1
	await get_tree().create_timer(1, false).timeout
	$"../CastRoll/Animation".play("Enter")
	await get_tree().create_timer(0.5).timeout
	finished.emit()
	
var egg_wave := 0.0

func setup_players() -> void:
	for i in players:
		i.hide()
	for i in CoopManager.players_connected:
		players[i].show()
		players[i].character = CoopManager.player_characters[i]
		players[i].power_state = BIG

func set_yoshi_shader_colours(yoshi_node, colour := 0) -> void:
	for i in 3:
		yoshi_node.material.set_shader_parameter("colour_" + str(i + 1), (Yoshi.colour_values[colour][i]) / 255.0)
	if SettingsManager.sprite_settings.yoshi == 0:
		yoshi_node.material.set_shader_parameter("arm_colour", Yoshi.yoshi_arm_orange)
		yoshi_node.material.set_shader_parameter("arm_2_colour", Yoshi.yoshi_arm_2_orange)
	else:
		yoshi_node.material.set_shader_parameter("arm_2_colour", Yoshi.colour_values[colour][1] / 255)
		yoshi_node.material.set_shader_parameter("arm_colour", Yoshi.colour_values[colour][0] / 255)

func set_baby_shader_colours(node, colour := 0) -> void:
	for i in 3:
		node.material.set_shader_parameter("colour_" + str(i + 1), (Yoshi.colour_values[colour][i]) / 255.0)

func _physics_process(delta: float) -> void:
	var index := 0
	egg_wave -= 16 * delta
	egg_wave = wrap(egg_wave, 0, PI * 2)
	for i in eggs:
		i.offset.y = sin(egg_wave + index) * 2
		index += 1
	$You/QuestionMark.visible = missing_eggs > 3

func move_players() -> void:
	for i in 4:
		move_player(i, player_positions[i])

func celebrate() -> void:
	for i in players:
		i.animation = ("Victory")
	$Peach/Animation.play("Wave")
	$RedYoshi/Animations.play("Jump")
	$YellowYoshi/Animations.play("Jump")
	$GreenYoshi/Animations.play("JumpFront")
	$BlueYoshi/Animations.play("JumpFront")

func reveal_eggs() -> void:
	$RedYoshi/Animations.play("Await")
	$YellowYoshi/Animations.play("Await")
	$GreenYoshi/Animations.play("AwaitFront")
	$BlueYoshi/Animations.play("AwaitFront")
	for i in 7:
		if SaveManager.current_save.eggs_rescued[i] == false:
			missing_egg(i)
			await get_tree().create_timer(0.5, false).timeout
		else:
			hatch_egg(i)
			await get_tree().create_timer(0.75, false).timeout

func missing_egg(id) -> void:
	missing_eggs += 1
	eggs[id].get_node("Outline").show()
	SoundManager.play_sfx(SoundManager.yoshi_spit, eggs[id])

func hatch_egg(id) -> void:
	eggs[id].self_modulate.a = 0
	eggs[id].get_node("BabyYoshi").show()
	SoundManager.play_sfx(SoundManager.yoshi_hatch, eggs[id])

func move_eggs() -> void:
	for id in 7:
		eggs[id].self_modulate.a = 1 if SaveManager.current_save.eggs_rescued[id] else 0
		move_node_to_position(eggs[id], egg_positions[id])

func move_yoshi() -> void:
	$YoshiFollower.yoshi_animations.play("Move")
	$YoshiFollower.yoshi_animations.speed_scale = 2
	await move_node_to_position($YoshiFollower, 200)
	$YoshiFollower.hide()
	$GreenYoshi.show()

func move_peach() -> void:
	
	await move_node_to_position($Peach, 184)
	$Peach/Animation.play("Idle")

func move_player(id, position):
	players[id].animation = ("Walk")
	await move_node_to_position(players[id], position)
	players[id].animation = ("FaceForward")

func move_node_to_position(node: Node2D, destination := 0.0) -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(node, "global_position:x", destination, node.global_position.distance_to(Vector2(destination, 0)) / 48)
	await tween.finished
	return
