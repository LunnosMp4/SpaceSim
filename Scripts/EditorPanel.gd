extends Control

@onready var SelectedLabel = $SelectedBody

func _ready():
	self.visible = false

func update_visibility(active):
	self.visible = active

func update_selected_body(body_type):
	SelectedLabel.text = body_type
