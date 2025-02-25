class_name Chuck
extends Enemy

var aggressive := false

@onready var state_machine: Node = $States
@onready var animations: AnimationPlayer = $Sprite/Animations
const CHUCK_FOOTBALL = preload("res://Instances/Prefabs/Projectiles/chuck_football.tscn")
@export var starting_direction := -1
@export_enum("Charge", "Clap", "Ball", "Dig", "Football", "Split", "Bounce", "Idle", "Leap", "Whistle") var state :=  ""
@export var whistle_summon := false

@export_range(2, 6) var ball_throw_amount := 4

var health := 5

signal player_entered_split

var damage_enabled := true

var clone := false

var player_direction := 1

func _ready() -> void:
	can_stomp_on = true
	direction = starting_direction
	await get_tree().physics_frame
	state_machine.transition_to(state)

func _process(_delta: float) -> void:
	sprite.scale.x = -direction

func _physics_process(_delta: float) -> void:
	player = CoopManager.get_closest_player(global_position)
	move_and_slide()

func summon_flash_particle() -> void:
	var node = flash.instantiate()
	node.global_position = player.global_position + Vector2(0, 16)
	get_parent().add_child(node)

func damage() -> void:
	if player != null:
		player.bounce_point_rel(global_position)
	health -= 1
	if health <= 0:
		player.play_sfx("kick")
		gib_type = 1
		die()
	if damage_enabled == false:
		return
	damage_enabled = false
	aggressive = true
	state_machine.transition_to("Hurt")


func _on_block_destruction_box_area_entered(area: Area2D) -> void:
	if state_machine.state.name == "Charge":
		if area.get_parent() is SpinBlock:
			if area.get_parent().item == null:
				area.get_parent().shatter()
		elif area.get_parent() is GrabBlock:
			if area.get_parent().active == false:
				area.get_parent().die()
			else:
				die()
		elif area.get_parent() is HeldObject:
			if area.get_parent().destructable:
				area.get_parent().die()

func summon_rock() -> void:
	pass

func summon_football() -> void:
	var node = CHUCK_FOOTBALL.instantiate()
	node.global_position = global_position + Vector2(8 * direction, 0)
	node.direction = direction
	SoundManager.play_sfx(SoundManager.kick, self)
	add_sibling(node)


func _on_timer_timeout() -> void:
	pass # Replace with function body.


func _on_split_detection_area_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		player_entered_split.emit()


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.owner is Fireball:
		health -= 1
		if health <= 0:
			player.play_sfx("kick")
			die()


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	if state_machine.state.name == "Charge":
		aggressive = false
		state_machine.transition_to("Idle")
