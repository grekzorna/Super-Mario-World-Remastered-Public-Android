class_name MapRoute
extends Resource

@export_node_path("MapPoint") var destination_point
@export var route_path: Curve2D
@export var reverse_path := false
@export var unlock_speed := 0.2
@export var route_unlocked := false
