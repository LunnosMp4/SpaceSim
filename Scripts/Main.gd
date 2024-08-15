extends Node2D

var planet_manager = null
var camera_controller = null
var input_handler = null
var ui_controller = null

func _ready():
	planet_manager = preload("res://Scripts/PlanetManager.gd").new()
	camera_controller = preload("res://Scripts/CameraControl.gd").new()
	ui_controller = preload("res://Scripts/UIController.gd").new()
	input_handler = preload("res://Scripts/InputManager.gd").new(self, planet_manager, ui_controller)
	
	Engine.time_scale *= 1
	Engine.physics_ticks_per_second *= 1

	add_child(planet_manager)
	add_child(camera_controller)
	add_child(input_handler)
	add_child(ui_controller)

	planet_manager.load_planets_and_stars()

func _process(_delta):
	ui_controller.update_info_panel(input_handler.selected_planet)
