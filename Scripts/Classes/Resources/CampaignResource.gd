class_name CampaignResource
extends Resource

@export var title := ""
@export_multiline var description := ""
@export var icon: Texture = null
@export_file("*.tscn") var starting_scene := ""
@export_file("*.tscn") var starting_map := ""
@export var achievements: Array[Achievement] = []
@export var map_areas: Array[MapArea] = []
