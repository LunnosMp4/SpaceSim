extends Node

@onready var notification_manager = get_node("/root/Node2D/NotificationManager")

var selected_body_type = null
var saved_states = []
var body_types = [
	{"type": "Terran Wet", "mass": 5.972e24},
	{"type": "Terran Dry", "mass": 6.39e23},
	{"type": "Islands", "mass": 5.5e23},
	{"type": "No atmosphere", "mass": 7.347e22},
	{"type": "Gas giant 1", "mass": 1.898e27},
	{"type": "Gas giant 2", "mass": 5.683e26},
	{"type": "Ice World", "mass": 1.024e24},
	{"type": "Lava World", "mass": 4.867e24},
	{"type": "Asteroid", "mass": 9.5e20},
	{"type": "Star", "mass": 1.989e33}
]

func _ready():
	selected_body_type = body_types[0]

func load_planets_and_stars():
	create_body("Sun", 1.989e30, "Star", Vector2(0, 0), Vector2(0, 0))
	create_body("Earth", 5.972e24, "Terran Wet", Vector2(-1000000, 0), Vector2(0, 4400))
	create_body("Moon", 7.347e22, "No atmosphere", Vector2(-999000, 0), Vector2(0, 4660))
	create_body("Mars", 6.39e23, "Terran Dry", Vector2(2000000, 0), Vector2(0, -3300))

func create_body(body_name, mass, type, position, velocity) -> RigidBody2D:
	var body_instance = load("res://Scenes/Planet.tscn").instantiate()
	var body = body_instance.get_node("Planet")
	if body is RigidBody2D:
		body.body_name = body_name
		body.custom_mass = mass * Constants.MASS_SCALE
		body.initial_velocity = velocity
		body.planet_type = type
		body.global_position = position
		add_child(body_instance)
		return body
	return null

func generate_planet_name() -> String:
	var letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	var numbers = "0123456789"
	var body_name = ""

	for i in range(3):
		body_name += letters[randi() % letters.length()]

	body_name += "-"

	for i in range(2):
		body_name += numbers[randi() % numbers.length()]

	return body_name

func create_body_with_velocity(start_pos, end_pos):
	save_current_state()
	
	if selected_body_type == null:
		selected_body_type = body_types[0]

	var body_instance = load("res://Scenes/Planet.tscn").instantiate()
	var body = body_instance.get_node("Planet")
	if body is RigidBody2D:
		body.custom_mass = selected_body_type["mass"] * Constants.MASS_SCALE
		body.planet_type = selected_body_type["type"]
		body.body_name = generate_planet_name()
		body.global_position = start_pos
		var velocity = (end_pos - start_pos) * 0.1
		body.linear_velocity = velocity
		add_child(body_instance)
		

func select_body(direction) -> String:
	var current_index = body_types.find(selected_body_type)
	var new_index = current_index + direction
	if new_index < 0:
		new_index = body_types.size() - 1
	if new_index >= body_types.size():
		new_index = 0
	selected_body_type = body_types[new_index]
	return selected_body_type["type"]

func save_current_state():
	var current_state = []
	for body in get_tree().get_nodes_in_group("planets"):
		var state = {
			"name": body.body_name,
			"mass": body.custom_mass,
			"type": body.planet_type,
			"position": body.global_position,
			"velocity": body.linear_velocity,
			"initial": body.initial_velocity
		}
		current_state.append(state)

	saved_states.append(current_state)
	
	notification_manager.notify("Save")

	await get_tree().create_timer(0.1).timeout

func restore_state():
	if saved_states.size() == 0:
		notification_manager.notify("No State to Restore")
		return

	var last_state = saved_states.pop_back()  # Get the last saved state

	# Remove all current planets
	for body_instance in get_tree().get_nodes_in_group("planets"):
		body_instance.get_parent().queue_free()

	notification_manager.notify("Undo")

	await get_tree().create_timer(0.1).timeout

	# Restore the last saved state
	for state in last_state:
		var body_instance = load("res://Scenes/Planet.tscn").instantiate()
		var body = body_instance.get_node("Planet")
		if body is RigidBody2D:
			body.body_name = state["name"]
			body.custom_mass = state["mass"]
			body.planet_type = state["type"]
			body.global_position = state["position"]
			body.linear_velocity = state["velocity"]
			add_child(body_instance)
			
