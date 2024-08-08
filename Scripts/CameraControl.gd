extends Camera2D

signal camera_updated

# Variables for camera movement
var drag_active = false
var last_mouse_position = Vector2()
var target_position = Vector2()

# Variables for zoom limits
var min_zoom = 0.1
var max_zoom = 3.0
var move_speed = 10.0  # Speed of camera movement interpolation

func _process(delta):
	handle_camera_movement()
	handle_zoom()
	smooth_camera_movement(delta)
	emit_signal("camera_updated")

func handle_camera_movement():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if not drag_active:
			drag_active = true
			last_mouse_position = get_global_mouse_position()
		else:
			var mouse_movement = last_mouse_position - get_global_mouse_position()
			target_position += mouse_movement / zoom  # Adjust movement speed with zoom
			last_mouse_position = get_global_mouse_position()
	else:
		drag_active = false

func smooth_camera_movement(delta):
	position = lerp(position, target_position, move_speed * delta)

func handle_zoom():
	var zoom_factor = 1.1
	if Input.is_action_just_pressed("zoom_in"):
		zoom *= zoom_factor
		if zoom.x > max_zoom:
			zoom = Vector2(max_zoom, max_zoom)
	elif Input.is_action_just_pressed("zoom_out"):
		zoom /= zoom_factor
		if zoom.x < min_zoom:
			zoom = Vector2(min_zoom, min_zoom)
