extends Node

var main_node = null
var planet_manager = null
var start_position = Vector2()
var is_dragging = false
var bodies = null
var selected_planet = null
@onready var drag_line = get_node("/root/Node2D/Line2D")
@onready var camera = get_node("/root/Node2D/Camera2D")

func _init(init_main_node, init_planet_manager):
	main_node = init_main_node
	planet_manager = init_planet_manager
	
func _process(_delta):
	if is_instance_valid(selected_planet):
		camera.set_position(selected_planet.global_position)
	else:
		selected_planet = null
		
	if is_dragging:
		update_drag_line()

func _input(event):
	handle_input(event)

func handle_input(event):
	if Input.is_action_just_pressed("camera_pan") and selected_planet:
		selected_planet = null
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			handle_click(main_node.get_global_mouse_position(), event)
				
	if Input.is_action_just_pressed("next_planet"):
		bodies = get_tree().get_nodes_in_group("planets")
		select_next_planet()

	if Input.is_action_just_pressed("previous_planet"):
		bodies = get_tree().get_nodes_in_group("planets")
		select_previous_planet()

func handle_click(mouse_position, event):
	if event.pressed:
		start_position = mouse_position
		var clicked_body = get_rigidbody_at_position(start_position)
		if clicked_body:
			select_planet(clicked_body)
			is_dragging = false
		elif selected_planet == null:
			start_drag(start_position)
	else:
		if is_dragging:
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

func end_drag(end_position):
	is_dragging = false
	drag_line.clear_points()
	planet_manager.create_body_with_velocity(start_position, end_position)

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

