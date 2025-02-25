extends Node
@onready var movie: VideoStreamPlayer = $Movie
@onready var vhs_filter: ColorRect = $VHSFilter
@onready var vhs: AudioStreamPlayer = $VHS


func _ready() -> void:
	await vhs.finished
	vhs_filter.show()
	movie.play()
	await movie.finished
	go_to_map()

func go_to_map() -> void:
	TransitionManager.transition_to_map(("res://Instances/Levels/Maps/YoshiIsland.tscn"), self)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		go_to_map()
