extends Node2D

var packet := {}

var player_rpc_id := -1

const packet_template := {"Username": "TestName",
							"Character": 0,
							"CurrentLevel": "",
							"Position": Vector2.ZERO,
							"CurrentPowerUp": null,
							"CurrentAnimation": "",
							"RidingYoshi": false,
							"Direction": 1,
							"AnimationSpeed": 0.0}

@onready var player_sprite: Node2D = $PlayerSpriteDisplay

@onready var username_label: Label = $UsernameLabel

func _ready() -> void:
	OnlineManager.recieved_level_player_data.connect(on_recieve_data)
	OnlineManager.player_disconnected.connect(on_player_disconnect)
	player_sprite.yoshi.custom_modulate_a = player_sprite.modulate.a

func _physics_process(delta: float) -> void:
	player_sprite.yoshi.custom_modulate_a = player_sprite.modulate.a

func on_recieve_data(data := {}) -> void:
	if is_instance_valid(GameManager.current_level):
		if data.has(player_rpc_id):
			show()
			apply_packet(data.get(player_rpc_id))
		else:
			hide()
	else:
		hide()

func on_player_disconnect(id := 0) -> void:
	if id == player_rpc_id:
		if visible:
			ParticleManager.summon_particle(ParticleManager.SPIN_IMPACT, global_position - Vector2(0, 8))
			SoundManager.play_sfx(SoundManager.magic, self)
		queue_free()

func apply_packet(packet_to_apply := {}) -> void:
	if player_rpc_id == 1:
		username_label.modulate = Color.YELLOW
	if GameManager.current_level.scene_file_path != packet_to_apply["CurrentLevel"]:
		hide()
		return
	player_sprite.power_state = load(packet_to_apply["CurrentPowerUp"])
	player_sprite.animation = (packet_to_apply["CurrentAnimation"])
	player_sprite.direction = packet_to_apply["Direction"]
	player_sprite.animation_speed = packet_to_apply["AnimationSpeed"]
	player_sprite.character = load(packet_to_apply["Character"])
	player_sprite.riding_yoshi = packet_to_apply["RidingYoshi"]
	player_sprite.yoshi_animation = packet_to_apply["YoshiAnimation"]
	player_sprite.yoshi_direction = packet_to_apply["FacingDirection"]
	player_sprite.yoshi_colour = packet_to_apply["YoshiColour"]
	global_position = packet_to_apply["Position"]
	if is_instance_valid(GameManager.current_level):
		visible = packet_to_apply["CurrentLevel"] == GameManager.current_level.scene_file_path
	else:
		hide()
	username_label.text = packet_to_apply["Username"]
