extends Node
@onready var letter_anim: AnimationPlayer = $Letter/LetterAnim
@onready var cutscene_player: AnimationPlayer = $AnimationPlayer
@onready var arrow: TextureRect = $Letter/Arrow
@onready var tutorial = preload("res://Instances/Levels/tutorial.tscn")
var can_continue := false

func _ready() -> void:
	await cutscene_player.animation_finished
	arrow.show()
	can_continue = true

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and can_continue:
		can_continue = false
		letter_anim.play("Leave")
		await get_tree().create_timer(2).timeout
		cutscene_player.play("Mario")
		await cutscene_player.animation_finished
		TransitionManager.transition_to_level(tutorial, self)

	if Input.is_action_just_pressed("start"):
		TransitionManager.transition_to_level(tutorial, self)
