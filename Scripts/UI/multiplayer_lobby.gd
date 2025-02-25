extends Node

@onready var ip_enter: LineEdit = $CanvasLayer/Control/VBoxContainer/IPEnter
@onready var join_button: Button = $CanvasLayer/Control/VBoxContainer/JoinButton
@onready var host_button: Button = $CanvasLayer/Control/VBoxContainer/HostButton
@onready var character_select: OptionButton = $CanvasLayer/Control/VBoxContainer2/OptionButton
@onready var user_name: LineEdit = $CanvasLayer/Control/UserName

@onready var save_select: Control = $CanvasLayer/Control/SaveSelect

signal open_save
signal game_entered

func _ready() -> void:
	OnlineManager.failed_connect.connect(fail_connect)
	OnlineManager.in_multiplayer_game = false
	get_tree().set_multiplayer(null)
	if OnlineManager.kick_message != "":
		SoundManager.play_ui_sound(SoundManager.wrong)
		show_message(OnlineManager.kick_message)
		OnlineManager.kick_message = ""

func enter_game() -> void:
	OnlineManager.user_name = user_name.text
	game_entered.emit()

func _on_join_button_pressed() -> void:
	if ip_enter.text == "":
		show_message("Empty Server Address!")
		SoundManager.play_ui_sound(SoundManager.wrong)
		return
	OnlineManager.join_server(ip_enter.text, int($CanvasLayer/Control/VBoxContainer/Port.text))
	show_message("Connecting...")
	await get_tree().create_timer(1, false).timeout
	if is_instance_valid(multiplayer.multiplayer_peer):
		open_save.emit()
		$CanvasLayer/Control/JoinButton.queue_free()
		$CanvasLayer/Control/HostButton.queue_free()
		await $CanvasLayer/Control/CharacterSelect.finished#
		enter_game()
	else:
		show_message("Failed to Connect!")

func _on_host_button_pressed() -> void:
	var port = $CanvasLayer/Control/VBoxContainer/Port.text
	open_save.emit()
	$CanvasLayer/Control/JoinButton.queue_free()
	$CanvasLayer/Control/HostButton.queue_free()
	await $CanvasLayer/Control/CharacterSelect.finished#
	OnlineManager.create_server(int(port))
	await OnlineManager.created_server
	enter_game()

func fail_connect() -> void:
	show_message("Failed Connection!")

func _process(delta: float) -> void:
	if user_name.text == "":
		if multiplayer.is_server():
			OnlineManager.user_name = "Host"
		else:
			OnlineManager.user_name = "Anon"
	if Input.is_action_just_pressed("ui_back"):
		TransitionManager.transition_to_menu(TransitionManager.TITLE_SCREEN, self)

func show_message(message := "") -> void:
	$CanvasLayer/Control/ApplyNotification/AnimationPlayer.play("RESET")
	$CanvasLayer/Control/ApplyNotification/Label.text = str(message)
	$CanvasLayer/Control/ApplyNotification/AnimationPlayer.play("Display")
