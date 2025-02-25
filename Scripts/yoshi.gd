class_name Yoshi
extends CharacterBody2D

@onready var state_machine: Node = $States
@onready var body: Sprite2D = $Body

@onready var yoshi_animations: AnimationPlayer = $YoshiAnimations
@onready var head: Sprite2D = $Body/Head
@onready var baby_sprite: Sprite2D = $BabySprite

var direction := 1
@export var colour: colours
var yoshi_stored: Node = null
enum colours {GREEN, RED, BLUE, YELLOW}
var player: Player = null
signal mounted

@onready var messages := [preload("res://Assets/Sprites/UI/Messages/GreenYoshi.png"), preload("res://Assets/Sprites/UI/Messages/RedYoshi.png"), preload("res://Assets/Sprites/UI/Messages/BlueYoshi.png"), preload("res://Assets/Sprites/UI/Messages/YellowYoshi.png")]

static var yoshi_amount := 0

static var colour_values := {colours.GREEN: 	[Color(0, 248, 0, 255), Color(0, 184, 0, 255), Color(0, 120, 0, 255)],
							colours.RED: 	[Color(248, 0, 0, 255), Color(184, 0, 0, 255), Color(136, 0, 0, 255)],
							colours.BLUE: 	[Color(136, 136, 248, 255), Color(104, 104, 216, 255), Color(64, 64, 216, 255)],
							colours.YELLOW: [Color(248, 248, 0, 255), Color(248, 192, 0, 255), Color(248, 120, 0, 255)]}

const yoshi_arm_orange := Color("f88800")
const yoshi_arm_2_orange := Color("b82800")


var first_ride := true

func _ready() -> void:
	yoshi_amount += 1

func _exit_tree() -> void:
	yoshi_amount -= 1

func _process(_delta: float) -> void:
	if yoshi_stored != null:
		head.frame = 4
	set_shader_colours()
	body.scale.x = direction
	if global_position.y > 114:
		queue_free()

func set_shader_colours() -> void:
	for i in 3:
		body.material.set_shader_parameter("colour_" + str(i + 1), (colour_values[colour][i]) / 255.0)
	if SettingsManager.sprite_settings.yoshi == 0:
		body.material.set_shader_parameter("arm_colour", yoshi_arm_orange)
	else:
		body.material.set_shader_parameter("arm_colour", colour_values[colour][0] / 255)
	for i in 3:
		baby_sprite.material.set_shader_parameter("colour_" + str(i + 1), (colour_values[colour][i]) / 255.0)

func _physics_process(_delta: float) -> void:
	move_and_slide()

func mount() -> void:
	mounted.emit()
	ParticleManager.summon_particle(ParticleManager.YOSHI_MOUNT, global_position)
	SoundManager.play_sfx(SoundManager.yoshi_mount, self)
	player.global_position = global_position
	player.yoshi_colour = colour
	player.yoshi_stored = yoshi_stored
	queue_free()

func play_hatch_animation() -> void:
	body.hide()
	state_machine.transition_to("Animate")
	$MainAnimation.play("Grow")
	if SettingsManager.settings_file.yoshi_spawn_pause:
		get_tree().paused = true
		process_mode = ProcessMode.PROCESS_MODE_ALWAYS
		await get_tree().create_timer(1.5, true).timeout
	else:
		await get_tree().create_timer(1.5, false).timeout
	state_machine.transition_to("Wait")
	if SaveManager.current_save.seen_yoshi_message[(colour)] == false:
		SaveManager.current_save.seen_yoshi_message[colour] = true
		GameManager.show_message(messages[colour])
	if SettingsManager.settings_file.yoshi_spawn_pause:
		get_tree().paused = false
		process_mode = ProcessMode.PROCESS_MODE_INHERIT


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		player = area.get_parent()
		if player.can_ride_yoshi and player.velocity.y > 25 and (not player.holding and not player.carrying and not player.carried):
			player.direction = direction
			player.facing_direction = direction
			mount()
			player.yoshi_mount(self)
		elif player.is_on_floor() and state_machine.state.name == "Wait" and player.velocity.y > 25:
			var knock_direction := 1
			if player.global_position.x > global_position.x:
				knock_direction = -1
			direction = knock_direction
			velocity.x += 100 * knock_direction
			SoundManager.play_sfx(SoundManager.kick, self)
