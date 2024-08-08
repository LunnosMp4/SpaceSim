extends Camera2D

@export var zoomSpeed : float = 10.0

var zoomTarget : Vector2
var dragStartMousePos = Vector2.ZERO
var dragStartCameraPos = Vector2.ZERO
var isDragging : bool = false

# Tolerance value to consider zoom and zoomTarget as equal
var tolerance = 0.0001

func _ready():
	zoomTarget = zoom

func _process(delta):
	Zoom(delta)
	SimplePan(delta)
	ClickAndDrag()

func Zoom(delta):
	if self.zoom.distance_to(zoomTarget) > tolerance:
		zoom = zoom.slerp(zoomTarget, zoomSpeed * delta)

func SimplePan(delta):
	var moveAmount = Vector2.ZERO
	if Input.is_action_pressed("camera_move_right"):
		moveAmount.x += 1

	if Input.is_action_pressed("camera_move_left"):
		moveAmount.x -= 1

	if Input.is_action_pressed("camera_move_up"):
		moveAmount.y -= 1

	if Input.is_action_pressed("camera_move_down"):
		moveAmount.y += 1

	moveAmount = moveAmount.normalized()
	position += moveAmount * delta * 1000 * (1/zoom.x)

func ClickAndDrag():
	if not isDragging and Input.is_action_just_pressed("camera_pan"):
		dragStartMousePos = get_viewport().get_mouse_position()
		dragStartCameraPos = position
		isDragging = true

	if isDragging and Input.is_action_just_released("camera_pan"):
		isDragging = false

	if isDragging:
		var moveVector = get_viewport().get_mouse_position() - dragStartMousePos
		position = dragStartCameraPos - moveVector * 1/zoom.x

# Function to set the zoom target from other scripts
func set_zoom_target(target_zoom: Vector2):
	zoomTarget = target_zoom

# Example input handling to change the zoom target
func _input(event):
	if Input.is_action_just_pressed("camera_zoom_in"):
		set_zoom_target(zoomTarget * 1.1)
		
	if Input.is_action_just_pressed("camera_zoom_out"):
		set_zoom_target(zoomTarget * 0.9)
