extends Node

var planets = []

func load_planets_and_stars():
	create_body("Sun", 1.989e28, "Star", Vector2(0, 0), Vector2(0, 0))
	create_body("Earth", 5.972e24, "Terran Wet", Vector2(-100000, 0), Vector2(0, 1500))
	create_body("Moon", 7.347e22, "No atmosphere", Vector2(-99000, 0), Vector2(0, 1750))
	create_body("Mars", 6.39e23, "Terran Dry", Vector2(200000, 0), Vector2(0, -1300))
		
func create_body(body_name, mass, type, position, velocity) -> RigidBody2D:
	var body_instance = load("res://Scenes/Planet.tscn").instantiate()
	var body = body_instance.get_node("Planet")
	if body is RigidBody2D:
		body.body_name = body_name
		body.custom_mass = mass
		body.initial_velocity = velocity
		body.planet_type = type
		add_child(body_instance)
		body_instance.global_position = position
		planets.append(body)
		return body
	return null

func create_body_with_velocity(start_pos, end_pos):
	var body_instance = load("res://Scenes/Planet.tscn").instantiate()
	var body = body_instance.get_node("Planet")
	if body is RigidBody2D:
		body.custom_mass = 1.989e30
		body.planet_type = "Star"
		add_child(body_instance)
		body_instance.global_position = start_pos
		
		# Calculate velocity based on the drag vector
		var velocity = (end_pos - start_pos) * 0.1
		body.linear_velocity = velocity
		planets.append(body)
