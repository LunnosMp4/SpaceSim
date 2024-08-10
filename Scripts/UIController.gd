extends Node

var info_panel = null

func _ready():
	info_panel = get_node("/root/Node2D/Ui/CanvasLayer/InfoPanel")

func update_info_panel(selected_planet):
	if selected_planet:
		info_panel.update_info_panel(selected_planet)
	else:
		info_panel.update_info_panel(null)
