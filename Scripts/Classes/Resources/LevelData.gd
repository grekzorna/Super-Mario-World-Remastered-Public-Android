class_name LevelInfo
extends Resource

@export var level_title := ""
@export_file("*.tscn") var level_scene_path := ""
@export_file("*.tscn") var start_cutscene_path := "" ## Cutscene level used before the base level, useful for ghost house and castles.
@export var has_secret_exit := true
@export var yoshi_allowed := true
@export var has_dragon_coins := true
@export var title_image: Texture = null
@export var dragon_coin_amount := 5
@export var counts_as_exit := true ## Some levels, such as the final castle and the switch palaces, dont count towards the total exit count. this helps keep track of that.,

@export var has_peach_coin := true

@export_group("Fast Travelling")
@export var map_point_warp := "" ## Map point path in tree for fast travel.
@export var map_scene_warp := "" ## Scene path used for map fast travel
