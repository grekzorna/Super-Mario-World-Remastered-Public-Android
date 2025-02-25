extends OptionNode

var level := {}

func _ready() -> void:#
	$Container/Icon.texture = level.title_image
	$Container/Title.text = level.level_title
