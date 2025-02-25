extends Control

@onready var lives_label: Label = $Container/Lives/HBoxContainer/LifeCount
@onready var dragon_coins_bar: HBoxContainer = $Container/StarPoints/VBoxContainer/DragonCoins
@onready var star_count: Label = $Container/StarPoints/Label
@onready var item_box_item: Sprite2D = $ItemBoxSprite
@onready var time_left_count: Label = $Container/Time/HBoxContainer/Label
@onready var score_count: Label = $Container/Score/ScoreText
@onready var coin_count: Label = $Container/Score/Coins/Label
@onready var player = get_parent()
@onready var player_title: TextureRect = $Container/Lives/PlayerTitle
@onready var peach_coin: TextureRect = $Container/StarPoints/PeachCoin
const PEACH_COIN = preload("res://Assets/Sprites/UI/HUD/PeachCoin.png")

var score := 0
var coins := 0
var dragon_coins := 0
var time_left := 0
var lives := 0
var star_points := 0
var crystal_coin_title := ""
var item_reserve: PlayerPowerUpState
var score_spacing = "00000000"

var race_timer := 0.0

var wide := true

var longer_time := false

var best_time := false
@onready var life_count: Control = $Container/Lives

var coins_collected := 0
@onready var player_icons: HBoxContainer = $Container/Lives/MultiplayerLetters
func _ready() -> void:
	item_reserve = GameManager.reserved_item
	update_itembox_visuals()
	if wide:
		$Container.size.x = size.x + 16
	else:
		$Container.size.x = 256
	$Container.position.x = (480 - $Container.size.x) / 2

func refresh_coin_list() -> void:
	pass

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_inventory"):
		GameManager.drop_current_held_item()
	player_title.texture = CoopManager.player_characters[0].HUDTitle
	player_title.visible = CoopManager.players_connected == 1
	player_icons.visible = CoopManager.players_connected > 1
	visible = is_instance_valid(CoopManager.get_first_any_player())
	if GameManager.current_level_info == null:
		GameManager.current_level_info = LevelInfo.new()
	if SaveManager.current_save == {}:
		SaveManager.current_save = SaveManager.save_file_template
	if GameManager.peach_coin_collected:
		$Container/StarPoints/PeachCoin.texture = PEACH_COIN
	if GameManager.reserved_item != null:
		item_box_item.show()
		item_box_item.texture = GameManager.reserved_item.item_sprite
		item_box_item.hframes = item_box_item.texture.get_width() / 16
	else:
		item_box_item.hide()
	for i in player_icons.get_children():
		i.visible = false
	for i in CoopManager.players_connected:
		if CoopManager.player_characters[i] != null:
			var icon = player_icons.get_children()[i]
			icon.visible = true
			icon.texture = CoopManager.player_characters[i].HUDLetter
	if is_instance_valid(GameManager.current_level):
		if GameManager.current_level.hide_hud == true:
			$Container/ItemBox.visible = GameManager.reserved_item != null
		else:
			$Container/ItemBox.visible = true
		for i in [$Container/Lives, $Container/Time, $Container/Score, $Container/StarPoints]:
			i.visible = not GameManager.current_level.hide_hud
	$Container/StarPoints/PeachCoin.visible = GameManager.current_level_info.has_peach_coin and SaveManager.current_save.peach_coins_unlocked
	coins = GameManager.coins
	score = GameManager.score
	lives = GameManager.lives
	dragon_coins = GameManager.dragon_coins
	time_left = GameManager.time
	star_points = GameManager.star_points
	time_left_count.text = str(time_left)
	for i in 4:
		dragon_coins_bar.get_child(i).modulate.a = 1 if GameManager.dragon_coins > i else 0 
	var level_amount := 5
	if is_instance_valid(GameManager.current_level_info):
		level_amount = GameManager.current_level_info.dragon_coin_amount
	coin_count.text = str(coins)
	score_count.text = str(score)
	lives_label.text = str(lives) if GameManager.inf_lives == false else "_"
	star_count.text = str(int(star_points))
	if lives < 1:
		life_count.modulate = Color(0.5, 0.5, 0.5, 1)
	else:
		life_count.modulate = Color.WHITE




func update_itembox_visuals() -> void:
	pass

func _input(event: InputEvent) -> void:
	pass

func drop_item() -> void:
	pass

func _on_timer_timeout() -> void:
	if GameManager.timer_frozen:
		return
	if is_instance_valid(CoopManager.get_first_any_player()) == false:
		return
	GameManager.time -= 1
	
