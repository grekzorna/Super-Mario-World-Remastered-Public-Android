extends Control

var current_campaign: CampaignResource = null
var campaign_list := [preload("res://Resources/Campaigns/Vanilla.tres")]
var campaign_path_list := []

var selected_index := 0

signal campaign_selected

var active := false

func _ready() -> void:
	get_campaigns()

func open() -> void:
	if campaign_list.size() <= 1:
		close()
		campaign_selected.emit()
		return
	show()
	await get_tree().physics_frame
	active = true

func close() -> void:
	active = false
	hide()


func _physics_process(delta: float) -> void:
	
	if active:
		if Input.is_action_just_pressed("ui_left"):
			selected_index -= 1
		if Input.is_action_just_pressed("ui_right"):
			selected_index += 1
	selected_index = wrap(selected_index, 0, campaign_list.size())
	current_campaign = campaign_list[selected_index]
	if active:
		if Input.is_action_just_pressed("ui_accept"):
			SoundManager.play_ui_sound(SoundManager.coin)
			GameManager.current_campaign = current_campaign
			campaign_selected.emit()
			close()
	if current_campaign.icon != null:
		$Template.texture = current_campaign.icon
	$CampaignTitle.text= current_campaign.title

func get_campaigns() -> void:
	for i in DirAccess.get_files_at("res://Resources/Campaigns/"):
		var file = "res://Resources/Campaigns/" + i.replace(".remap", "")
		var camp_resource = load(file)
		if campaign_list.has(camp_resource) == false:
			campaign_list.append(camp_resource)
