extends HBoxContainer

@onready var level_title_label: RichTextLabel = $LevelTitle

@onready var standard_clear_indicator: TextureRect = $Clears/Standard
@onready var secret_clear_indicator: TextureRect = $Clears/Secret
@onready var dragon_coins_indicator: TextureRect = $DragonCoins
@onready var peach_coin_indicator: TextureRect = $PeachCoin

var level_unlocked := false
var level_completed := false
var secret_completed := false
var has_dragon_coins := true
var dragon_coins := false
var has_secret := false
var has_peach_coin := false
var got_peach_coin := false

var level: LevelInfo = null

const CLEAR_COMPLETE = preload("res://Assets/Sprites/UI/StatusScreen/Icons/ClearComplete.png")
const CLEAR_SECRET = preload("res://Assets/Sprites/UI/StatusScreen/Icons/ClearSecret.png")
const COIN_COMPLETE = preload("res://Assets/Sprites/UI/StatusScreen/Icons/CoinComplete.png")
const CLEAR_EMPTY = preload("res://Assets/Sprites/UI/StatusScreen/Icons/ClearEmpty.png")
const COIN_EMPTY = preload("res://Assets/Sprites/UI/StatusScreen/Icons/CoinEmpty.png")
const P_COIN_EMPTY = preload("res://Assets/Sprites/UI/StatusScreen/Icons/PCoinEmpty.png")
const PEACH_COIN_COMPLETE = preload("res://Assets/Sprites/UI/StatusScreen/Icons/PeachCoinComplete.png")

func _ready() -> void:
	await get_tree().physics_frame
	update_info()

func update_icons() -> void:
	if level_completed:
		standard_clear_indicator.texture = CLEAR_COMPLETE
	else:
		standard_clear_indicator.texture = CLEAR_EMPTY
	if secret_completed:
		secret_clear_indicator.texture = CLEAR_SECRET
	else:
		secret_clear_indicator.texture = CLEAR_EMPTY
	if dragon_coins:
		dragon_coins_indicator.texture = COIN_COMPLETE
	else:
		dragon_coins_indicator.texture = COIN_EMPTY
	if got_peach_coin:
		peach_coin_indicator.texture = PEACH_COIN_COMPLETE
	else:
		peach_coin_indicator.texture = P_COIN_EMPTY
	peach_coin_indicator.modulate.a = 1 if level.has_peach_coin else 0
	peach_coin_indicator.visible = SaveManager.current_save.peach_coins_unlocked
	if level.has_dragon_coins == false:
		dragon_coins_indicator.modulate.a = 0
	else:
		dragon_coins_indicator.modulate.a = 1
	if level.has_secret_exit == false:
		secret_clear_indicator.modulate.a = 0
	else:
		secret_clear_indicator.modulate.a = 1
	if level.counts_as_exit == false:
		standard_clear_indicator.modulate.a = 0
	else:
		standard_clear_indicator.modulate.a = 1

func update_info() -> void:
	if level == null:
		hide()
		return
	else:
		show()
	level_title_label.clear()
	if level.title_image != null:
		level_title_label.add_image(level.title_image, 8, 8)
		level_title_label.add_text(" ")
	else:
		level_title_label.add_text("  ")
	level_title_label.add_text(level.level_title.to_upper())
	level_unlocked = SaveManager.current_save.unlocked_levels.has(level.resource_path)
	level_completed = SaveManager.current_save.beaten_levels.has(level.resource_path)
	secret_completed = SaveManager.current_save.special_beaten_levels.has(level.resource_path)
	dragon_coins = SaveManager.current_save.dragon_levels.has(level.resource_path)
	got_peach_coin = SaveManager.current_save.peach_coins_collected.has(level.resource_path)
	for i in [level_title_label, $Clears, $DragonCoins, peach_coin_indicator]:
		if level_unlocked == false:
			i.modulate.a = 0
		else:
			i.modulate.a = 1
			update_icons()
		
