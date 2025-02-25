class_name FlipPanel
extends CollisionShape2D

@onready var panel_texture: NinePatchRect = $Panel
@onready var climb_area: Climbable = $ClimbableArea
@onready var player_marker: Marker2D = $Marker2D

var player: Player = null

func _ready() -> void:
	panel_texture.size = shape.size
	panel_texture.position = -shape.size / 2
	climb_area.get_child(0).shape = (shape.duplicate())
	climb_area.get_child(0).scale = Vector2(0.5, 0.5)

func animate_turn() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(panel_texture, "scale", panel_texture.scale * Vector2(-1, 1), 0.5)

func _process(_delta: float) -> void:
	if player != null:
		player_marker.global_position = player.global_position
	panel_texture.position = (-shape.size / 2) * panel_texture.scale

func _on_climbable_area_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		area.get_parent().flip_panel = self
		player = area.get_parent()


func _on_climbable_area_area_exited(area: Area2D) -> void:
	if area.get_parent() is Player:
		area.get_parent().flip_panel = null
		player = null
