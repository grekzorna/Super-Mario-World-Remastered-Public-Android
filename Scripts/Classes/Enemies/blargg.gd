extends Enemy
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var one_shot := false
@export var moving := false

@onready var starting_pos := global_position

func _ready() -> void:
	direction = -1
	sprite.hide()

func _physics_process(delta: float) -> void:
	if moving:
		velocity.x = 50 * direction
	else:
		velocity.x = 0
	sprite.scale.x = -direction
	move_and_slide()

func loop() -> void:
	sprite.show()
	animation_player.play("Peek")
	await animation_player.animation_finished
	get_direction()
	animation_player.play("Leap")
	await animation_player.animation_finished
	if one_shot:
		queue_free()
	global_position = starting_pos
	loop()

func get_direction() -> void:
	var target_player = CoopManager.get_closest_player(global_position)
	if target_player.global_position.x > global_position.x:
		direction = 1
	else:
		direction = -1
