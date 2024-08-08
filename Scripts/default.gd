extends Node2D

var PlanetScene = preload("res://Scenes/planet.tscn")
var selected_planet = null
var camera = null
var bodies = []

func _ready():
	camera = get_node("Camera2D")
	
	var sun_instance = PlanetScene.instantiate()
	var sun = sun_instance.get_node("Planet")
	if sun is RigidBody2D:
		sun.custom_mass = 1.989e28
		sun.initial_velocity = Vector2(0, 0)
		sun.planet_type = "Star"
		add_child(sun_instance)
		sun_instance.global_position = Vector2(0, 0)
	
	var earth_instance = PlanetScene.instantiate()
	var earth = earth_instance.get_node("Planet")
	if earth is RigidBody2D:
		earth.custom_mass = 5.972e24
		earth.initial_velocity = Vector2(0, 1500)
		earth.planet_type = "Terran Wet"
		earth.set_sun_position(Vector2(0, 0))
		add_child(earth_instance)
		earth_instance.global_position = Vector2(-100000, 0)

	var moon_instance = PlanetScene.instantiate()
	var moon = moon_instance.get_node("Planet")
	if moon is RigidBody2D:
		moon.custom_mass = 7.347e22
		moon.initial_velocity = Vector2(0, 1650)
		moon.planet_type = "No atmosphere"
		moon.set_sun_position(Vector2(0, 0))
		add_child(moon_instance)
		moon_instance.global_position = Vector2(-98240, 0)

	var mars_instance = PlanetScene.instantiate()
	var mars = mars_instance.get_node("Planet")
	if mars is RigidBody2D:
		mars.custom_mass = 6.39e23
		mars.initial_velocity = Vector2(0, -1300)
		mars.planet_type = "Terran Dry"
		mars.set_sun_position(Vector2(0, 0))
		add_child(mars_instance)
		mars_instance.global_position = Vector2(200000, 0)

	bodies = get_tree().get_nodes_in_group("planets")


func _input(event):
	if Input.is_action_just_pressed("camera_pan") && selected_planet:
		selected_planet = null
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var clicked_position = get_global_mouse_position()
		var clicked_body = get_rigidbody_at_position(clicked_position)
		
		if clicked_body:
			if selected_planet == clicked_body:
				selected_planet = null
			else:
				camera.set_zoom_target(Vector2(1.5, 1.5))
				selected_planet = clicked_body
		else:
			if selected_planet:
				selected_planet = null
			else:
				# Create a new planet
				var asteroid_instance = PlanetScene.instantiate()
				var asteroid = asteroid_instance.get_node("Planet")
				if asteroid is RigidBody2D:
					asteroid.custom_mass = 1e10
					asteroid.initial_velocity = Vector2(0, 0)
					asteroid.planet_type = "Asteroid"
					asteroid.set_sun_position(Vector2(0, 0))
					add_child(asteroid_instance)
					asteroid_instance.global_position = clicked_position
					
	if Input.is_action_just_pressed("next_planet"):
		if selected_planet:
			var index = bodies.find(selected_planet)
			if index < bodies.size() - 1:
				selected_planet = bodies[index + 1]
			else:
				selected_planet = bodies[0]
		else:
			selected_planet = bodies[0]

	if Input.is_action_just_pressed("previous_planet"):
		if selected_planet:
			var index = bodies.find(selected_planet)
			if index > 0:
				selected_planet = bodies[index - 1]
			else:
				selected_planet = bodies[bodies.size() - 1]
		else:
			selected_planet = bodies[bodies.size() - 1]

func get_rigidbody_at_position(position):
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = position
	var result = space_state.intersect_point(query)
	if result.size() > 0:
		var body = result[0]['collider']
		if body is RigidBody2D:
			return body
	return null

func _process(delta):
	if is_instance_valid(selected_planet):
		camera.set_position(selected_planet.global_position)
	else:
		selected_planet = null
