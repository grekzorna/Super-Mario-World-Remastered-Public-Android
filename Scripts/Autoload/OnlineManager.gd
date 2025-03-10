extends Node

const PORT := 25565

signal joined_server
signal created_server
const CHAT_MESSAGE = preload("res://Instances/UI/chat_message.tscn")
const ONLINE_FIELD_PLAYER_DISPLAY = preload("res://Instances/Prefabs/online_field_player_display.tscn")
const ONLINE_PLAYER_DISPLAY = preload("res://Instances/Prefabs/online_player_display.tscn")
signal recieved_level_player_data(data)
signal player_disconnected(id)

signal failed_connect(ERR)
signal failed_create

var in_multiplayer_game := false
var is_server := false
var peer: ENetMultiplayerPeer = null
var user_name := ""

var kick_message := ""

var chat_enabled := false

var player_usernames := {}
var player_level_displays := []

func _ready() -> void:
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	multiplayer.peer_connected.connect(player_connected)

func _physics_process(delta: float) -> void:
	if is_instance_valid(multiplayer):
		if multiplayer.is_server():
			client_recieve_data.rpc(player_data)
	$ChatLog/Container/TextEdit.visible = chat_enabled
	if in_multiplayer_game:
		if Input.is_action_just_pressed("server_talk") and chat_enabled == false:
			open_chat_box()
		elif Input.is_action_just_pressed("send_message") and chat_enabled:
			send_chat_message($ChatLog/Container/TextEdit.text)
			$ChatLog/Container/TextEdit.clear()
			chat_enabled = false

func open_chat_box() -> void:
	chat_enabled = true

var player_data_packet := {"Username": "TestName",
							"Character": null,
							"CurrentLevel": "",
							"InLevel": false,
							"InMap": false,
							"Position": Vector2.ZERO,
							"CurrentPowerUp": null,
							"CurrentAnimation": "",
							"RidingYoshi": false,
							"Direction": 1,
							"AnimationSpeed": 0.0,
							"CurrentMap": ""}

var player_data := {}

func create_server(server_port := 0) -> void:
	multiplayer.multiplayer_peer.close()
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(server_port)
	multiplayer.multiplayer_peer = peer
	await get_tree().physics_frame
	if err == OK:
		created_server.emit()
		in_multiplayer_game = true
		is_server = true
		multiplayer.peer_connected.connect(player_connected)
		multiplayer.peer_disconnected.connect(disconnect_player)
		var ip_address =  IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1)
		print(ip_address)
		#send_message({"Sender": "Server", "ID": -1, "Message": "Your server is being hosted on: " + str(ip_address)})
	else:
		failed_create.emit()
		multiplayer.multiplayer_peer.close()

func join_server(server_ip := "", server_port := 0) -> void:
	multiplayer.multiplayer_peer.close()
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(server_ip, server_port)
	multiplayer.multiplayer_peer = peer
	await get_tree().create_timer(1.5, false).timeout
	if err == OK:
		joined_server.emit()
		in_multiplayer_game = true
		is_server = false
		add_current_players()
		multiplayer.peer_connected.connect(player_connected)
		multiplayer.peer_disconnected.connect(disconnect_player)
		await get_tree().create_timer(0.5, false).timeout
		print(user_name)
		server_upload_username.rpc_id(1, user_name)
	else:
		failed_connect.emit(err)
		multiplayer.multiplayer_peer.close()

func upload_level_player_packet(player: Player) -> void:
	if in_multiplayer_game:
		var packet = player_data_packet.duplicate()
		packet["Position"] = player.global_position
		packet["CurrentLevel"] = GameManager.current_level.scene_file_path
		packet["CurrentAnimation"] = player.sprite.animation
		packet["Direction"] = player.direction
		packet["RidingYoshi"] = player.riding_yoshi
		packet["CurrentPowerUp"] = player.power_state.resource_path
		packet["Character"] = (CoopManager.player_characters[0]).resource_path
		packet["AnimationSpeed"] = player.sprite.speed_scale
		packet["Username"] = OnlineManager.user_name
		packet["YoshiAnimation"] = player.yoshi_animations.current_animation
		packet["FacingDirection"] = player.facing_direction
		packet["YoshiColour"] = CoopManager.yoshi_colours[0]
		packet["InLevel"] = true
		packet["InMap"] = false
		server_recieve_packet.rpc_id(1, packet)

func upload_field_player_packet(player: MapPlayer) -> void:
	if in_multiplayer_game:
		var packet = player_data_packet.duplicate()
		packet["Position"] = player.global_position
		packet["CurrentMap"] = GameManager.current_map.scene_file_path
		packet["Character"] = CoopManager.player_characters[0].resource_path
		packet["CurrentAnimation"] = player.sprite.animation
		packet["YoshiColour"] = CoopManager.yoshi_colours[0]
		packet["RidingYoshi"] = CoopManager.player_yoshis[0]
		packet["InLevel"] = false
		packet["InMap"] = true
		packet["Username"] = OnlineManager.user_name
		server_recieve_packet.rpc_id(1, packet)

@rpc("any_peer", "call_local", "reliable")
func server_recieve_packet(packet := {}) -> void:
	var player_id = multiplayer.get_remote_sender_id()
	player_data[player_id] = packet

func send_chat_message(message := "") -> void:
	send_message.rpc_id(1, {"Sender": user_name, "Character": CoopManager.player_characters[0].resource_path, "ID": multiplayer.get_unique_id(), "Message": message})

@rpc("authority", "call_local", "reliable")
func client_recieve_data(data := {}) -> void:
	player_data = data
	recieved_level_player_data.emit(data)

@rpc("any_peer", "call_local", "reliable")
func send_message(data := {}) -> void:
	client_recieve_message.rpc(data)

@rpc("authority", "call_local", "reliable")
func client_recieve_message(message_data := {}) -> void:
	var node = CHAT_MESSAGE.instantiate()
	node.sender = message_data["Sender"]
	node.sender_id = message_data["ID"]
	node.message = message_data["Message"]
	if message_data.has("Character"):
		node.character = load(message_data["Character"])
	$ChatLog/Container/VBoxContainer.add_child(node)

@rpc("authority", "call_remote", "reliable")
func kick_to_lobby(message := "") -> void:
	if TransitionManager.scene_loading:
		await TransitionManager.scene_loaded
	if is_instance_valid(GameManager.current_level):
		TransitionManager.transition_to_menu("res://Instances/Levels/multiplayer_lobby.tscn", GameManager.current_level)
	elif is_instance_valid(GameManager.current_map):
		TransitionManager.transition_to_menu("res://Instances/Levels/multiplayer_lobby.tscn", GameManager.current_map)
	kick_message = message
	multiplayer.multiplayer_peer.close()

@rpc("any_peer", "call_local", "unreliable")
func server_upload_username(username := "") -> void:
	if player_usernames.has(multiplayer.get_remote_sender_id()):
		return
	player_usernames[multiplayer.get_remote_sender_id()] = username
	client_recieve_message.rpc({"Sender": "Server", "ID": -1, "Message": username + " Has Connected!"})

func player_connected(player_id := 0, player_username := "") -> void:
	add_player_display(player_id)

func disconnect_player(player_id := 0) -> void:
	player_disconnected.emit(player_id)
	kick_message = ""
	if player_id == 1:
		kick_to_lobby("Server Closed")
	if is_server:
		if player_usernames.has(player_id):
			send_message.rpc_id(1, {"Sender": "Server", "ID": -1, "Message": player_usernames[player_id] + " Has Disconnected!"})
	player_usernames.erase(player_id)

func add_current_players() -> void:
	for i in multiplayer.get_peers():
		if player_level_displays.has(i) == false:
			add_player_display(i)

func close_server() -> void:
	kick_to_lobby.rpc("Sever Closed")

func add_player_display(id := 0) -> void:
	var node = ONLINE_PLAYER_DISPLAY.instantiate()
	node.player_rpc_id = id
	player_level_displays.append(id)
	get_tree().root.add_child(node)
	
	node = ONLINE_FIELD_PLAYER_DISPLAY.instantiate()
	node.player_rpc_id = id
	get_tree().root.add_child(node)
