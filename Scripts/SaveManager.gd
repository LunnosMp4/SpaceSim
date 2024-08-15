extends Node

var main_node = null
var saved_states = []

func _init(_main_node):
	main_node = _main_node

func save_current_state():
	var current_state = []
	for body in main_node.get_tree().get_nodes_in_group("planets"):
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

	await main_node.get_tree().create_timer(0.1).timeout

func restore_state():
	if saved_states.size() == 0:
		print("No State to Restore")
		return

	var last_state = saved_states.pop_back()  # Get the last saved state

	# Remove all current planets
	for body_instance in main_node.get_tree().get_nodes_in_group("planets"):
		body_instance.get_parent().queue_free()

	await main_node.get_tree().create_timer(0.1).timeout

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
			
