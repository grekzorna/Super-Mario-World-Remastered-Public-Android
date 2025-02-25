extends Node

@onready var sprites := [$Mario, $Luigi, $Toad, $Toadette, $LuigiSMAS, $LuigiSMA2]
const chars := ["Mario", "Luigi", "Toad", "Toadette", "LuigiSMAS", "LuigiSMA2"]
const power_sprites := ["Small", "Big", "Fire", "Ice", "Shell", "Propeller"]
const BIG = preload("res://Resources/PlayerSpriteFrames/Mario/Small.tres")

var current_power_state := "Small"

@onready var anim_name_label: Label = $VBoxContainer/AnimName
@onready var power_state_label: Label = $VBoxContainer/PowerState
const AnimationTest = preload("res://Scripts/Classes/States/Player/animation_test.gd")
var anim_index := 0
var power_index := 0
var current_animation := ""

func _ready() -> void:
	update_sprites()
	var state = AnimationTest.new()
	state.test()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("move_left_0"):
		anim_index -= 1
		anim_index = wrap(anim_index, 0, BIG.get_animation_names().size())
		current_animation = BIG.get_animation_names()[anim_index]
		update_sprites()
	if Input.is_action_just_pressed("move_right_0"):
		anim_index += 1
		anim_index = wrap(anim_index, 0, BIG.get_animation_names().size() )
		current_animation = BIG.get_animation_names()[anim_index]
		update_sprites()
	
	if Input.is_action_just_pressed("move_up_0"):
		power_index += 1
		power_index = wrap(power_index, 0, power_sprites.size())
		current_power_state = power_sprites[power_index]
		update_sprites()
	if Input.is_action_just_pressed("move_down_0"):
		power_index -= 1
		power_index = wrap(power_index, 0, power_sprites.size())
		current_power_state = power_sprites[power_index]
		update_sprites()

func update_sprites() -> void:
	for i in 6:
		sprites[i].sprite_frames = load("res://Resources/PlayerSpriteFrames/" + chars[i] + "/" + current_power_state + ".tres")
		sprites[i].play(current_animation)
	anim_name_label.text = current_animation
	power_state_label.text = current_power_state
