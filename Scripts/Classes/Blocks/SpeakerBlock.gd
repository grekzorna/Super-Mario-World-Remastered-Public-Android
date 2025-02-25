extends Block

@export var message: Texture = null
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var message_animation: AnimationPlayer = $CanvasLayer/AnimationPlayer
@onready var message_rect: TextureRect = $CanvasLayer/Message/MessageRect


signal message_closed

var can_close_message := false

func _ready() -> void:
	$CanvasLayer2.visible = message == null
	$CanvasLayer2/Label.text = ("Message Block is missing its message! \n Please report!!! Scene: " + str(GameManager.current_level.scene_file_path))

func block_hit(direction := "") -> void:
	if can_hit == false:
		return
	can_hit = false
	animation_player.play("Hit")
	await get_tree().create_timer(0.25, false).timeout
	await show_message()
	await get_tree().create_timer(1, false).timeout
	can_hit = true

func show_message() -> void:
	SoundManager.play_sfx(SoundManager.message, self)
	await GameManager.show_message(message)
