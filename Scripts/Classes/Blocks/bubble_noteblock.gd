extends Block


@onready var hitboxes = [$Hitboxes/Up, $Hitboxes/Down]
@onready var animations: AnimationPlayer = $Animations
@onready var sprite: AnimatedSprite2D = $Sprite

@export var can_respawn := false
@export var new_bubble_texture: Texture2D = null ## IGNORE, only meant for the sprite settings things


var bouncing := false
signal bounced
const BUBBLES = preload("res://Instances/Particles/Misc/bubbles.tscn")
var bounce_target: Node = null

func spawn() -> void:
	hitboxes[0].area_entered.connect(up_hit)
	hitboxes[1].area_entered.connect(down_hit)

	await animations.animation_finished
	pop()

func pop() -> void:
	ParticleManager.summon_particle(ParticleManager.PUFF_SPR, global_position)
	SoundManager.play_sfx(SoundManager.clap, self)
	queue_free()

func block_hit(direction := "Up") -> void:
	if empty:
		return
	if not bouncing:
		summon_bubbles()
	bouncing = true
	if item != null:
		empty = true
		summon_item(item)

func summon_bubbles() -> void:
	var node = BUBBLES.instantiate()
	node.global_position = global_position
	node.emitting = true
	add_sibling(node)
	if SettingsManager.sprite_settings.bubble == 1:
		node.texture = new_bubble_texture

func left_hit(area: Area2D) -> void:
	if check_node(area.owner):
		block_hit("Left")
		animations.play("Left")

func right_hit(area: Area2D) -> void:
	if check_node(area.owner):
		block_hit("Right")
		animations.play("Right")

func up_hit(area: Area2D) -> void:
	if check_node(area.owner):
		block_hit("Up")
		animations.play("Up")

func down_hit(area: Area2D) -> void:
	if check_node(area.owner):
		block_hit("Down")
		can_bounce = true
		animations.play("Down")

func launch_node() -> void:
	if bounce_target is Player:
		if bounce_target.ground_pounding:
			bounce_target.state_machine.transition_to("Normal")
			bounce_target.velocity.y = -500
		bounce_target.can_jump = true
		bounce_target.bounce_off()
		if Input.is_action_pressed(CoopManager.get_player_input_str("jump", bounce_target.player_id)):
			bounce_target.velocity.y = -400
		bounce_target = null

func check_node(node: Node) -> bool:
	if node is Player and not bouncing:
		bounce_target = node
	return node is Player and not bouncing


func _on_animations_animation_started(anim_name: StringName) -> void:
	await get_tree().create_timer(0.1, false).timeout
	SoundManager.play_sfx(SoundManager.spring, self)


func _on_animations_animation_finished(anim_name: StringName) -> void:
	can_bounce = false


func _on_up_area_exited(area: Area2D) -> void:
	if area.owner is Player:
		player = null
