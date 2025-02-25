class_name OnOffSwitch
extends Block

@export var on_nodes: Node = null
@export var off_nodes: Node = null

var on := true

var can_switch := true

signal changed

var changing = false

func spawn() -> void:
	await get_tree().physics_frame
	for i in GameManager.current_level.get_children():
		if i is OnOffSwitch:
			i.changed.connect(switch)

func physics_update(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_clear"):
		block_hit_override()

func block_hit_override(direction := "") -> void:
	if can_switch == false:
		return
	can_switch = false
	SoundManager.play_sfx(SoundManager.switch_activate, self)
	emit_signal("changed")
	await get_tree().create_timer(0.2, false).timeout
	can_switch = true


func switch() -> void:
	on = not on

func update(delta: float) -> void:
	if on:
		visuals.play("On")
	else:
		visuals.play("Off")
	
