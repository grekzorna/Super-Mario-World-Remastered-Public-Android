@tool
extends TileMap

@export var atlas_id := 0
@export var tile_pattern_file_name := "Test.txt"
@export var generate_tiles := false


@onready var autumn_tileset: TileSet = preload("res://Resources/TileSets/AutumnMapTileset.tres")
@onready var standard_tileset: TileSet = preload("res://Resources/TileSets/StandardMapTileset.tres")
var data = []

func _ready() -> void:
	if Engine.is_editor_hint() == false:
		set_layer_modulate(1, Color(0,0,0,0))
	if GameManager.autumn:
		tile_set = autumn_tileset
		AchievementManager.unlock_achievement(preload("res://Resources/Achievements/Completionist/Autumn.tres"))
	else:
		tile_set = standard_tileset

func _process(delta: float) -> void:
	if generate_tiles:
		add_tiles()
		generate_tiles = false

func add_tiles() -> void:
	if Engine.is_editor_hint():
		pass
	else:
		return
	clear()
	data = []
	load_data()
	
	await get_tree().create_timer(0.1).timeout
	for i in data:
		print("FUCK")
		if get_cell_atlas_coords(atlas_id, Vector2(i[1][0], i[1][1])):
			set_cell(0, Vector2(i[0][0], i[0][1]), atlas_id, Vector2(i[1][0], i[1][1]))

func load_data() -> void:
	var file = FileAccess.open("res://Assets/TilesetData/" + tile_pattern_file_name + ".txt", FileAccess.READ)
	data = str_to_var(file.get_as_text())
