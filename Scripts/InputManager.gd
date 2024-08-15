extends Node

var main_node = null
var planet_manager = null
var ui_controller = null

var start_position = Vector2()
var is_dragging = false
var bodies = null
var selected_planet = null

var cursor = preload("res://Assets/Images/SpaceUI/cursor_pointerFlat.png")
var cursorHover = preload("res://Assets/Images/SpaceUI/cursor_hand.png")

@onready var drag_line = get_node("/root/Node2D/DragLine")
@onready var prediction_line = get_node("/root/Node2D/PredictionLine")
@onready var camera = get_node("/root/Node2D/Camera2D")

func _init(_main_node, _planet_manager, _ui_controller):
	main_node = _main_node
	planet_manager = _planet_manager
	ui_controller = _ui_controller
	
func _process(_delta):
	if is_instance_valid(selected_planet):
		camera.set_position(selected_planet.global_position)
	else:
		selected_planet = null
		
	if is_dragging:
		update_drag_line()
		update_prediction_line()

func _input(event):
	handle_input(event)

var last_hover_state = false

func handle_input(event):
	if Input.is_action_just_pressed("camera_pan") and selected_planet:
		selected_planet = null
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			handle_click(main_node.get_global_mouse_position(), event)

	if Input.is_action_just_pressed("undo_action"):
		planet_manager.restore_state()
		
	if Input.is_action_just_pressed("save_action"):
		planet_manager.save_current_state()

	if Input.is_action_just_pressed("editor_mode"):
		ui_controller.editor_panel_visibility(true)
		
	if Input.is_action_just_released("editor_mode"):
		ui_controller.editor_panel_visibility(false)

	if is_dragging and Input.is_action_just_released("editor_mode"):
		cancel_drag()

	if Input.is_action_just_pressed("camera_next_planet"):
		bodies = get_tree().get_nodes_in_group("planets")
		select_next_planet()

	if Input.is_action_just_pressed("camera_previous_planet"):
		bodies = get_tree().get_nodes_in_group("planets")
		select_previous_planet()
		
	if Input.is_action_pressed("next_body"):
		ui_controller.editor_selected_body(planet_manager.select_body(1))
		
	if Input.is_action_pressed("previous_body"):
		ui_controller.editor_selected_body(planet_manager.select_body(-1))

func handle_click(mouse_position, event):
	if event.pressed:
		start_position = mouse_position
		var clicked_body = get_rigidbody_at_position(start_position)
		if clicked_body:
			select_planet(clicked_body)
			is_dragging = false
		elif selected_planet == null and Input.is_action_pressed("editor_mode"):
			start_drag(start_position)
	else:
		if is_dragging and Input.is_action_pressed("editor_mode"):
			end_drag(mouse_position)

func select_planet(planet):
	if selected_planet == planet:
		selected_planet = null
	else:
		selected_planet = planet

func select_next_planet():
	if selected_planet:
		var index = bodies.find(selected_planet)
		if index < bodies.size() - 1:
			selected_planet = bodies[index + 1]
		else:
			selected_planet = bodies[0]
	else:
		selected_planet = bodies[0]

func select_previous_planet():
	if selected_planet:
		var index = bodies.find(selected_planet)
		if index > 0:
			selected_planet = bodies[index - 1]
		else:
			selected_planet = bodies[bodies.size() - 1]
	else:
		selected_planet = bodies[bodies.size() - 1]

func start_drag(mouse_position):
	is_dragging = true
	drag_line.clear_points()
	drag_line.add_point(mouse_position)
	drag_line.add_point(mouse_position)

func update_drag_line():
	var zoom_factor = camera.zoom.length()
	drag_line.width = min(1.0 / zoom_factor * 5.0, 500.0)
	if is_dragging:
		drag_line.set_point_position(1, main_node.get_global_mouse_position())

func update_prediction_line():
	var zoom_factor = camera.zoom.length()
	prediction_line.width = min(1.0 / zoom_factor * 5.0, 500.0)
	var end_position = main_node.get_global_mouse_position()
	var velocity = (end_position - start_position) * 0.774
	prediction_line.clear_points()
	
	var new_planet_mass = planet_manager.selected_body_type["mass"] * Constants.MASS_SCALE
	var simulated_positions = simulate_trajectory(start_position, velocity, new_planet_mass)
	
	for pos in simulated_positions:
		prediction_line.add_point(pos)

func end_drag(end_position):
	is_dragging = false
	drag_line.clear_points()
	prediction_line.clear_points()
	planet_manager.create_body_with_velocity(start_position, end_position)
	
func cancel_drag():
	is_dragging = false
	drag_line.clear_points()
	prediction_line.clear_points()

func get_rigidbody_at_position(mouse_position):
	var space_state = main_node.get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_position
	var result = space_state.intersect_point(query)
	if result.size() > 0:
		var body = result[0]['collider']
		if body is RigidBody2D:
			return body
	return null

func simulate_trajectory(position, velocity, mass):
	var simulated_positions = []
	var simulation_time = 10.0  # Simulate for 10 seconds
	var time_step = get_physics_process_delta_time()
	var current_position = position
	var current_velocity = velocity
	
	for t in range(int(simulation_time / time_step)):
		var acceleration = Vector2.ZERO
		for body in get_tree().get_nodes_in_group("planets"):
			var direction = body.global_position - current_position
			var distance_squared = direction.length_squared()
			if distance_squared < 0.1:
				distance_squared = 0.1  # Avoid extreme forces
			var force_magnitude = Constants.G * (body.get_custom_mass() * mass) / distance_squared
			acceleration += direction.normalized() * force_magnitude / mass
		
		current_velocity += acceleration * time_step
		current_position += current_velocity * time_step
		simulated_positions.append(current_position)
	
	return simulated_positions
