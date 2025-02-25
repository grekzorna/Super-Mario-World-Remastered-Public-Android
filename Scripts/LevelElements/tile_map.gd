@tool
extends TileMap

@export var enable_autumn := true

@export_group("Tileset Setup Automation")
@export var generate_shapes := false
@export var physics_layer := 0
@export var one_way := false
@export var atlas_id := 0
@export var first_atlas_size := Vector2.ZERO ## Size of the atlas that the shapes are being copied from in tile amount (i.e. 16 tiles by 16 tiles)
@export var tiles_to_span := Vector2.ZERO ## Amount of tilesets in each direction there are (i.e. 2x to the left and 1x down = Vector2(3, 2)
const DEFAULT = preload("res://Resources/TileSets/Default.tres")
const DEFAULT_AUTUMN = preload("res://Resources/TileSets/DefaultAutumn.tres")

const tileset_texture_changes := {
	0: [
		"res://Assets/Sprites/Tilesets/Terrains/OverworldTerrain.png",
		"res://Assets/Sprites/Tilesets/Terrains/OverworldMakerTerrain.png",
		"res://Assets/Sprites/Tilesets/Terrains/OverworldAutumnTerrain.png",
		"res://Assets/Sprites/Tilesets/Terrains/OverworldAutumnMakerTerrain.png"
	],
	
	1: [
		"res://Assets/Sprites/Tilesets/Semi-Solids/OverworldSemiSolids.png",
		"res://Assets/Sprites/Tilesets/Semi-Solids/OverworldMakerSemiSolids.png",
		"res://Assets/Sprites/Tilesets/Semi-Solids/OverworldAutumnSemiSolids.png",
		"res://Assets/Sprites/Tilesets/Semi-Solids/OverworldAutumnMakerSemiSolids.png"
	],
	
	2: [
		"res://Assets/Sprites/Tilesets/Terrains/UndergroundTerrain.png",
		"res://Assets/Sprites/Tilesets/Terrains/UndergroundMakerTerrain.png",
		"res://Assets/Sprites/Tilesets/Terrains/UndergroundAutumnTerrain.png",
		"res://Assets/Sprites/Tilesets/Terrains/UndergroundAutumnMakerTerrain.png"
	],
	
	3: [
		"res://Assets/Sprites/Tilesets/Semi-Solids/UndergroundSemiSolids.png",
		"res://Assets/Sprites/Tilesets/Semi-Solids/UndergroundMakerSemiSolids.png",
		"res://Assets/Sprites/Tilesets/Semi-Solids/UndergroundAutumnSemiSolids.png",
		"res://Assets/Sprites/Tilesets/Semi-Solids/UndergroundAutumnMakerSemiSolids.png"
	],
	
	4: [
		"res://Assets/Sprites/Tilesets/Terrains/ForestTerrain.png",
		"res://Assets/Sprites/Tilesets/Terrains/ForestTerrain.png",
		"res://Assets/Sprites/Tilesets/Terrains/ForestAutumnTerrain.png",
		"res://Assets/Sprites/Tilesets/Terrains/ForestAutumnTerrain.png"
	],
	
	8: [
		"res://Assets/Sprites/Tilesets/MiscTiles.png",
		"res://Assets/Sprites/Tilesets/MiscTiles.png",
		"res://Assets/Sprites/Tilesets/MiscAutumnTiles.png",
		"res://Assets/Sprites/Tilesets/MiscAutumnTiles.png"
	],
	
	9: [
		"res://Assets/Sprites/Tilesets/Decorations/OverworldBushes.png",
		"res://Assets/Sprites/Tilesets/Decorations/OverworldBushes.png",
		"res://Assets/Sprites/Tilesets/Decorations/AutumnBushes.png",
		"res://Assets/Sprites/Tilesets/Decorations/AutumnBushes.png"
	],
	
	10: [
		"res://Assets/Sprites/Tilesets/Decorations/MushroomTiles.png",
		"res://Assets/Sprites/Tilesets/Decorations/MushroomTiles.png",
		"res://Assets/Sprites/Tilesets/Decorations/MushroomAutumnTiles.png",
		"res://Assets/Sprites/Tilesets/Decorations/MushroomAutumnTiles.png"
	],
	
	13: [
		"res://Assets/Sprites/Tilesets/Terrains/CastleTerrain.png",
		"res://Assets/Sprites/Tilesets/Terrains/CastleMakerTerrain.png",
		"res://Assets/Sprites/Tilesets/Terrains/CastleTerrain.png",
		"res://Assets/Sprites/Tilesets/Terrains/CastleMakerTerrain.png",
	],
	16: [
		"res://Assets/Sprites/Tilesets/Decorations/ForestTileset.png",
		"res://Assets/Sprites/Tilesets/Decorations/ForestTileset.png",
		"res://Assets/Sprites/Tilesets/Decorations/AutumnForestTileset.png",
		"res://Assets/Sprites/Tilesets/Decorations/AutumnForestTileset.png"
	],
	
	17: [
		"res://Assets/Sprites/Tilesets/Terrains/SwitchPalaceTiles.png",
		"res://Assets/Sprites/Tilesets/Terrains/SwitchPalaceMakerTiles.png",
		"res://Assets/Sprites/Tilesets/Terrains/SwitchPalaceTiles.png",
		"res://Assets/Sprites/Tilesets/Terrains/SwitchPalaceMakerTiles.png"
	]
}

var tile_variation_index := 0

func _ready() -> void:
	if Engine.is_editor_hint() == false:
		if GameManager.autumn and enable_autumn and SettingsManager.settings_file.autumn_type == 0:
			if SettingsManager.sprite_settings.tileset_colour_style == 1:
				tile_variation_index = 3
			else:
				tile_variation_index = 2
		elif SettingsManager.sprite_settings.tileset_colour_style == 1:
			tile_variation_index = 1
		else:
			tile_variation_index = 0
		for i in tileset_texture_changes.keys():
			var source = tile_set.get_source(i)
			if source is TileSetAtlasSource:
				source.texture = load(tileset_texture_changes[i][tile_variation_index])

func _process(delta: float) -> void:
	if generate_shapes:
		generate_shapes = false
		copy_tile_shapes()

func copy_tile_shapes() -> void:
	var copy_tile_size = first_atlas_size
	var tile_atlas: TileSetAtlasSource = tile_set.get_source(atlas_id)
	for tile_y in copy_tile_size.y:
		for tile_x in copy_tile_size.x:
			var tile_to_copy_data: TileData = tile_atlas.get_tile_data(Vector2((tile_x), (tile_y)), 0)
			
			for update_y in tiles_to_span.y:
				for update_x in tiles_to_span.x:
					var tile_to_update_data: TileData = tile_atlas.get_tile_data(Vector2(tile_x + (update_x * first_atlas_size.x), tile_y + (first_atlas_size.y * update_y)), 0)
					if tile_to_update_data != null:
						tile_to_update_data.set_collision_polygons_count(physics_layer, tile_to_copy_data.get_collision_polygons_count(physics_layer))
						tile_to_update_data.set_collision_polygon_points(physics_layer, 0, tile_to_copy_data.get_collision_polygon_points(physics_layer, 0))
						tile_to_update_data.set_collision_polygon_one_way(physics_layer, 0, one_way)
						tile_to_update_data.set_collision_polygon_one_way_margin(physics_layer, 0, 1)
	
	ResourceSaver.save(tile_set, tile_set.resource_path)
	print("Done")
