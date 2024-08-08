extends Node2D

var PlanetScene = preload("res://Scenes/planet.tscn")

func _ready():
	var sun_instance = PlanetScene.instantiate()
	var sun = sun_instance.get_node("Planet")
	if sun is RigidBody2D:
		sun.custom_mass = 1.989e26
		sun.initial_velocity = Vector2(0, 0)
		sun.planet_type = "Star"
		add_child(sun_instance)
		sun_instance.global_position = Vector2(0, 0)
	
	var earth_instance = PlanetScene.instantiate()
	var earth = earth_instance.get_node("Planet")
	if earth is RigidBody2D:
		earth.custom_mass = 5.972e24
		earth.initial_velocity = Vector2(0, 1000)
		earth.planet_type = "Terran Wet"
		add_child(earth_instance)
		earth_instance.global_position = Vector2(-10000, 0)

	#var other_planet_instance = PlanetScene.instantiate()
	#var other_planet = other_planet_instance.get_node("Planet")
	#if other_planet is RigidBody2D:
		#other_planet.custom_mass = 5.972e24
		#other_planet.initial_velocity = Vector2(0, -100)
		#other_planet.planet_type = "Terran Dry"
		#add_child(other_planet_instance)
		#other_planet_instance.global_position = Vector2(1000, 0)

	# Add more planets with different positions and velocities as needed

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var planet_instance = PlanetScene.instantiate()
		var planet = planet_instance.get_node("Planet")
		if planet is RigidBody2D:
			planet.custom_mass = 5.972e24
			planet.initial_velocity = Vector2(0, 0)
			add_child(planet_instance)
			planet_instance.global_position = get_global_mouse_position()
