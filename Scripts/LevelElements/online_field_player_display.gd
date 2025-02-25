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

var yoshi_colour := 0
const YOSHI_COLOURS := [[Color("00F800"), Color("00B800"), Color("D8C8A8"), Color("D08048")], [Color("F80000"), Color("B80000"), Color("F8D0C0"), Color("E87958")], [Color("8888F8"), Color("6868D8"), Color("E800B0"), Color("F8D0C0")], [Color("F8F800"), Color("F8C000"), Color("F88800"), Color("B82800")]]
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var username_label: Label = $UsernameLabel

func _ready() -> void:
	OnlineManager.recieved_level_player_data.connect(on_recieve_data)
	OnlineManager.player_disconnected.connect(on_player_disconnect)

func on_recieve_data(data := {}) -> void:
	if is_instance_valid(GameManager.current_map):
		if data.has(player_rpc_id):
			show()
			apply_packet(data.get(player_rpc_id))
		else:
			hide()
	else:
		hide()

func _process(_delta: float) -> void:
	sprite.material.set_shader_parameter("alpha", sprite.self_modulate.a)
	sprite.material.set_shader_parameter("colour_1", YOSHI_COLOURS[CoopManager.yoshi_colours[0]][0])
	sprite.material.set_shader_parameter("colour_2", YOSHI_COLOURS[CoopManager.yoshi_colours[0]][1])
	sprite.material.set_shader_parameter("arm_colour", YOSHI_COLOURS[CoopManager.yoshi_colours[0]][2])
	sprite.material.set_shader_parameter("arm_2_colour", YOSHI_COLOURS[CoopManager.yoshi_colours[0]][3])

func on_player_disconnect(id := 0) -> void:
	if id == player_rpc_id:
		if visible:
			ParticleManager.summon_particle(ParticleManager.SPIN_IMPACT, global_position - Vector2(0, 8))
			SoundManager.play_sfx(SoundManager.magic, self)
		queue_free()

func apply_packet(packet_to_apply := {}) -> void:
	if player_rpc_id == 1:
		username_label.modulate = Color.YELLOW
	sprite.sprite_frames = load(packet_to_apply["Character"]).map_sprites
	if sprite.sprite_frames.has_animation(packet_to_apply["CurrentAnimation"]):
		sprite.play(packet_to_apply["CurrentAnimation"])
	sprite.scale.x = packet_to_apply["Direction"]
	yoshi_colour = packet_to_apply["YoshiColour"]
	sprite.speed_scale = 1
	global_position = packet_to_apply["Position"]
	if is_instance_valid(GameManager.current_map):
		visible = packet_to_apply["CurrentMap"] == GameManager.current_map.scene_file_path
	else:
		hide()
	username_label.text = packet_to_apply["Username"]
