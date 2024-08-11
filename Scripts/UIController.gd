extends Node

var info_panel = null
var editor_panel = null

func _ready():
	info_panel = get_node("/root/Node2D/Ui/CanvasLayer/InfoPanel")
	editor_panel = get_node("/root/Node2D/Ui/CanvasLayer/EditorPanel")
	

func update_info_panel(selected_planet):
	if selected_planet:
		info_panel.update_info_panel(selected_planet)
	else:
		info_panel.update_info_panel(null)

func editor_panel_visibility(active):
	editor_panel.update_visibility(active)

func editor_selected_body(body_type):
	editor_panel.update_selected_body(body_type)
