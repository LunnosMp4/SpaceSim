extends Node2D

@onready var line = $Line2D
@onready var planet = $Planet
@onready var camera = get_viewport().get_camera_2d()

var points = PackedVector2Array()
var min_distance = 25.0
var update_rate = 10
var frame_count = 0

func _process(_delta):
	frame_count += 1
	if frame_count % update_rate == 0:
		if is_instance_valid(planet):
			var current_position = planet.global_position - global_position
			if points.size() == 0 or points[points.size() - 1].distance_to(current_position) > min_distance:
				points.append(current_position)
				line.points = points
			
			if points.size() > 3000:
				points.remove_at(0)
				line.points = points
				
			if camera != null:
				var zoom_factor = camera.zoom.length()
				line.width = min(1.0 / zoom_factor * 5.0, 500.0)
		else:
			queue_free()
