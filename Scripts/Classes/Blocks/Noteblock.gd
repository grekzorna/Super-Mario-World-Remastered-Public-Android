extends Block


@onready var hitboxes = [$Hitboxes/Up, $Hitboxes/Down]
@onready var animations: AnimationPlayer = $Animations
@onready var sprite: AnimatedSprite2D = $Sprite

var bouncing := false
signal bounced

var bounce_target: Node = null

func spawn() -> void:
	hitboxes[0].area_entered.connect(up_hit)
	hitboxes[1].area_entered.connect(down_hit)

func block_hit(direction := "Up") -> void:
	if empty:
		return
	if item != null:
		empty = true
		summon_item(item)

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
