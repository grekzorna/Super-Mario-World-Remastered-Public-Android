@tool
class_name PlayerSpriteDisplay
extends Node2D


@export var power_state: PlayerPowerUpState = null
@export var character: CharacterResource = load("res://Resources/Characters/Mario.tres")
@export var animation := ""
@export var yoshi_animation := "Move"
var direction := 1
var current_character: CharacterResource = null

@export var animation_speed := 2.0
@export var riding_yoshi := false
var yoshi_direction := 1
var yoshi_colour := 0

@export var animation_force_frame := -1

var spinning := false

@export var animating := false

var animation_velocity := Vector2.ZERO

var prev_position := Vector2.ZERO
@onready var character_script: Node = $CharacterScript
var sliding := false
var current_power_state: PlayerPowerUpState = null
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var power_sprite_extras: Node2D = $Sprite/PowerSpriteExtras
@onready var yoshi_animations: AnimationPlayer = $Yoshi/YoshiAnimations
@onready var yoshi: Node2D = $Yoshi
@onready var player_yoshi_joint: Node2D = $Yoshi/MarioPoint
@onready var yoshi_tongue_line: Line2D = $Yoshi/Body/Head/TongueLine
@onready var yoshi_tongue_node: Sprite2D = $Yoshi/Body/Head/Tongue
@onready var state_machine: StateMachine = $StateMachine

func is_on_floor() -> bool:
	return $FloorDetect.is_colliding()

func _ready() -> void:
	update_display()

func _physics_process(delta: float) -> void:
	sprite.speed_scale = animation_speed
	sprite.scale.x = direction
	if animation_force_frame != -1:
		sprite.frame = animation_force_frame
	if is_instance_valid(sprite.sprite_frames):
		if sprite.sprite_frames.has_animation(animation):
			sprite.play(animation)
	if riding_yoshi:
		sprite.play("YoshiIdle")
	yoshi.visible = riding_yoshi
	yoshi_animations.play(yoshi_animation)
	yoshi_animations.speed_scale = animation_speed
	yoshi.colour = yoshi_colour
	yoshi_tongue_line.set_point_position(1, yoshi_tongue_line.to_local(yoshi_tongue_node.global_position))
	yoshi_tongue_line.set_point_position(0, Vector2(yoshi_tongue_line.get_point_position(0).x, yoshi_tongue_line.to_local(yoshi_tongue_node.global_position).y))
	yoshi_tongue_line.visible = yoshi_tongue_node.visible
	if not Engine.is_editor_hint():
		yoshi.colour = yoshi_colour
	if riding_yoshi:
		sprite.scale.x = yoshi_direction
		sprite.position = player_yoshi_joint.position - Vector2(0, 8)
	else:
		sprite.position = Vector2(0, -16)
	yoshi.scale.x = yoshi_direction
	if current_power_state != power_state:
		update_display()
	if current_character != character:
		set_character(character)
		update_display()
	if animating:
		animation_velocity = (global_position - prev_position) / delta
	prev_position = global_position

func set_character(char: CharacterResource) -> void:
	current_character = char
	if current_character != null:
		if char.character_script != null:
			character_script.queue_free()
			character_script = Node.new()
			character_script.set_script(char.character_script)
			add_child(character_script)

func update_display() -> void:
	if is_instance_valid(character) == false:
		return
	set_character(character)
	sprite.sprite_frames = load("res://Resources/PlayerSpriteFrames/" + character.character_name + "/" + power_state.sprite_frame_name + ".tres")
	for i in power_sprite_extras.get_children():
		i.queue_free()
	for i in power_state.sprite_extras:
		if character.power_sprite_extra_replaces.has(i):
			create_power_sprite_extra(character.power_sprite_extra_replaces[i])
		else:
			create_power_sprite_extra(i)
	current_power_state = power_state

func create_power_sprite_extra(scene: PackedScene) -> void:
	var node: PowerUpSpriteExtra = scene.instantiate()
	if node.show_on_displays == false:
		node.queue_free()
		return
	node.player = self
	power_sprite_extras.add_child(node)
	node.display = true
	if character.power_sprite_extra_offsets.has(node.extra_name):
		node.position += character.power_sprite_extra_offsets[node.extra_name]
	node.player = self

func set_to_player_info(player_id := 0) -> void:
	power_state = load(CoopManager.player_power_states[player_id])
	yoshi_colour = CoopManager.yoshi_colours[player_id]
	character = CoopManager.player_characters[player_id]
