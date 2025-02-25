class_name FishingLevel
extends Level

@onready var main_animations: AnimationPlayer = $MainAnimations
@onready var player_animations: AnimationPlayer = $Player/PlayerAnimations

@onready var main_selection: Control = $UI/MainSelection
@onready var menu_pointer: CenterContainer = $UI/MainSelection/Pointer
@onready var menu_panels = [$UI/MainSelection/Choices/Label2/Panel, $UI/MainSelection/Choices/Label/Panel]
@onready var choice_animations: AnimationPlayer = $UI/MainSelection/ChoiceAnimations

const PULL_ITEM_FROM_WATER = preload("res://Assets/Audio/SFX/pullItemFromWater.wav")
const BOB = preload("res://Assets/Audio/SFX/bob.wav")
const FAST_REEL = preload("res://Assets/Audio/SFX/fastReel.wav")

@export var menu_active := false
var menu_choice := 0

signal bob_land

var fishing := false
var line_cast := false
var casting_line := false
var cast_charge := 0.0
var bob_landed := false
var reeling_fish := false
var fish_hooked := false
const MAX_CAST_CHARGE := 100
const CAST_MULT := Vector2(1.5, 1)

@onready var fishing_bob: CharacterBody2D = $FishingBob
@onready var pole_line_point: Node2D = $Player/Pole/LinePoint
@onready var bob_line_point: Node2D = $FishingBob/Sprite/LinePoint
@onready var fishing_line: Line2D = $Player/Pole/FishingLine

@onready var caught_fish: StaticBody2D = $CaughtFish


func _physics_process(delta: float) -> void:
	if menu_active:
		handle_menu_selections(delta)
	if fishing:
		handle_fishing(delta)

func _process(delta: float) -> void:
	fishing_line.set_point_position(0, fishing_line.to_local(pole_line_point.global_position))
	fishing_line.set_point_position(1, fishing_line.to_local(bob_line_point.global_position))

func handle_menu_selections(delta: float) -> void:
	if Input.is_action_just_pressed("move_right_0"):
		menu_choice += 1
		SoundManager.play_ui_sound(SoundManager.select)
	if Input.is_action_just_pressed("move_left_0"):
		menu_choice -= 1
		SoundManager.play_ui_sound(SoundManager.select)
	menu_choice = clamp(menu_choice, 0, 1)
	var active_panel = menu_panels[menu_choice]
	menu_pointer.global_position.x = lerpf(menu_pointer.global_position.x, active_panel.global_position.x + (active_panel.size.x / 2), delta * 20)
	for i in menu_panels:
		var node = i.get_parent()
		if active_panel == i:
			node.position.y = lerpf(node.position.y, 0, delta * 20)
		else:
			node.position.y = lerpf(node.position.y, 16, delta * 20)
	if Input.is_action_just_pressed("ui_accept"):
		menu_selected(active_panel.get_parent())

func menu_selected(selected_panel: Control) -> void:
	menu_active = false
	SoundManager.play_ui_sound(SoundManager.correct)
	for i in 5:
		selected_panel.modulate.a = 0
		await get_tree().create_timer(0.1).timeout
		selected_panel.modulate.a = 1
		await get_tree().create_timer(0.1).timeout
	choice_animations.play_backwards("Show")
	await get_tree().process_frame
	menu_active = false
	if menu_choice == 0:
		leave_pond()
	else:
		start_fishing()
	return

func handle_fishing(delta: float) -> void:
	if fish_hooked and not reeling_fish:
		if Input.is_action_just_pressed("jump_0"):
			reel_start()
	elif casting_line:
		if Input.is_action_just_released("jump_0"):
			casting_line = false
			player_animations.play("FishingThrow")
			line_cast = true
			cast_line()
		cast_charge += 50 * delta
		cast_charge = clamp(cast_charge, 10, MAX_CAST_CHARGE)
		print(cast_charge)
	elif not line_cast:
		if Input.is_action_just_pressed("jump_0"):
			casting_line = true
			player_animations.play("FishingCharge")
	if line_cast:
		handle_fishing_bob_physics(delta)

func cast_line() -> void:
	fishing_bob.show()
	bob_landed = false
	fishing_bob.velocity = Vector2(cast_charge, -cast_charge) * CAST_MULT
	await bob_land
	player_animations.play("FishingSit")
@onready var bob_timer: Timer = $FishingBob/BobTimer

func handle_fishing_bob_physics(delta: float) -> void:
	var bob_sprite = $FishingBob/Sprite
	fishing_bob.velocity.y += 5
	if fishing_bob.is_on_floor():
		fishing_bob.velocity.x = lerpf(fishing_bob.velocity.x, 0, delta * 20)
		if bob_landed == false:
			bob_land.emit()
		bob_landed = true
	if fish_hooked == false:
		bob_sprite.position.y = lerpf(bob_sprite.position.y, 0, delta * 5)
	if reeling_fish:
		$FishingBob/Sprite/LinePoint.position = Vector2(randi_range(6, 8), randi_range(-5, -7))
	else:
		$FishingBob/Sprite/LinePoint.position = Vector2(7, -6)
	fishing_bob.move_and_slide()

func bob_down() -> void:
	$FishingBob/Sprite.position.y = randi_range(4, 8)
	SoundManager.play_sfx(BOB, fishing_bob)
	Input.start_joy_vibration(0, 0.1, 0.2, 0.1)
	if randi_range(0, 5) == 0:
		bob_hooked()
		bob_timer.stop()
		return
	bob_timer.start(randf_range(3, 4))
	

func reel_start() -> void:
	player_animations.play("FishReel")
	$Player/HookAlert.hide()
	reeling_fish = true
	Input.start_joy_vibration(0, 1, 1, 2)
	await get_tree().create_timer(2, false).timeout
	fish_caught()

func bob_hooked() -> void:
	$Player/HookAlert.show()
	SoundManager.play_ui_sound(SoundManager.switch_activate)
	$FishingBob/Sprite.position.y = 16
	fish_hooked = true
	Input.start_joy_vibration(0, 0.5, 0.5, 0.1)
	await get_tree().create_timer(1).timeout
	if not reeling_fish:
		fish_hooked = false
		bob_timer.start(randi_range(3, 5))
		$Player/HookAlert.hide()

func leave_pond() -> void:
	$Player/PlayerAnimations.play("Leave")
	await $Player/PlayerAnimations.animation_finished
	TransitionManager.transition_to_map(GameManager.current_map_path, self, false)

func start_fishing() -> void:
	fishing = true
	line_cast = false

func fish_caught() -> void:
	fish_hooked = false
	line_cast = false
	reeling_fish = false
	fish_fly_to_player()
	player_animations.play("FishCaught")
	choice_animations.play("Show")
	menu_active = true

@onready var fishing_player: Node2D = $Player
@onready var fish_animation: AnimationPlayer = $CaughtFish/AnimationPlayer

func fish_fly_to_player() -> void:
	SoundManager.play_sfx(PULL_ITEM_FROM_WATER, caught_fish)
	caught_fish.show()
	caught_fish.global_position = fishing_bob.global_position
	fish_animation.play("Fly")
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(caught_fish, "global_position:x", fishing_player.global_position.x, 0.8)
