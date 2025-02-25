extends TileMapLayer

@export var enable_autumn := true

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
		"res://Assets/Sprites/Tilesets/Semi-Solids/UndergroundMakerSemiSolids.png"
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
