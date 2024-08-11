extends Camera2D

@export var zoomSpeed : float = 10.0

var zoomTarget : Vector2
var dragStartMousePos = Vector2.ZERO
var dragStartCameraPos = Vector2.ZERO
var isDragging : bool = false
var tolerance = 0.0001

var selected_planet = null  # Reference to the selected planet

func _ready():
	zoomTarget = zoom

func _process(delta):
	SimplePan(delta)
	ClickAndDrag()
	Zoom(delta)

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

func set_zoom_target(target_zoom: Vector2):
	zoomTarget = target_zoom

func _input(_event):
	if Input.is_action_just_pressed("camera_zoom_in") and !Input.is_action_just_pressed("next_body"):
		set_zoom_target(zoomTarget * 1.1)
		
	if Input.is_action_just_pressed("camera_zoom_out") and !Input.is_action_just_pressed("previous_body"):
		set_zoom_target(zoomTarget * 0.9)

# Function to update the selected planet from the main game logic
func update_selected_planet(planet):
	selected_planet = planet
