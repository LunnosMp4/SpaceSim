extends RigidBody2D

const G = 6.67430e-15

var custom_mass = 5.972e24
var initial_velocity = Vector2()
var last_force = Vector2()
var position_history = []
var is_colliding = false
var planet_type = "Terran Wet"

@onready var planets = {
	"Terran Wet": preload("res://Planets/Rivers/Rivers.tscn"),
	"Terran Dry": preload("res://Planets/DryTerran/DryTerran.tscn"),
	"Islands": preload("res://Planets/LandMasses/LandMasses.tscn"),
	"No atmosphere": preload("res://Planets/NoAtmosphere/NoAtmosphere.tscn"),
	"Gas giant 1": preload("res://Planets/GasPlanet/GasPlanet.tscn"),
	"Gas giant 2": preload("res://Planets/GasPlanetLayers/GasPlanetLayers.tscn"),
	"Ice World": preload("res://Planets/IceWorld/IceWorld.tscn"),
	"Lava World": preload("res://Planets/LavaWorld/LavaWorld.tscn"),
	"Asteroid": preload("res://Planets/Asteroids/Asteroid.tscn"),
	"Black Hole": preload("res://Planets/BlackHole/BlackHole.tscn"),
	"Galaxy": preload("res://Planets/Galaxy/Galaxy.tscn"),
	"Star": preload("res://Planets/Star/Star.tscn"),
}

func _ready():
	self.mass = custom_mass

	var planet_scene = planets[planet_type]
	var planet = planet_scene.instantiate()
	planet.set_global_position(Vector2(-50, -50))
	add_child(planet)

	add_to_group("planets")
	print("Planet ready with mass: ", custom_mass)
	apply_central_impulse(initial_velocity)
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _physics_process(_delta):
	for body in get_tree().get_nodes_in_group("planets"):
		if body != self:
			apply_gravity(body, _delta)
			
	position_history.append(get_global_position())
	if position_history.size() > 1000:
		position_history.pop_front()
			
	queue_redraw()

func apply_gravity(body, _delta):
	if body is RigidBody2D:
		var direction = body.global_position - global_position
		var distance_squared = direction.length_squared()
		if distance_squared < 0.1:
			distance_squared = 0.1  # Avoid division by zero and extreme forces
		if body.has_method("get_custom_mass"):
			var body_mass = body.get_custom_mass()
			var force_magnitude = G * (custom_mass * body_mass) / distance_squared
			var force = direction.normalized() * force_magnitude
			apply_force(force * _delta, Vector2())  # Apply continuous force
			last_force = force  # Store the last applied force for debug drawing

func _on_body_entered(body):
	is_colliding = true

func _on_body_exited(body):
	is_colliding = false

func get_custom_mass():
	return custom_mass
# Debug drawing
func _draw():
	draw_line(Vector2(), last_force, Color(1, 0, 0))
	if position_history.size() > 1:
		for i in range(position_history.size() - 1):
			draw_line(position_history[i] - global_position, position_history[i + 1] - global_position, Color(0, 1, 0), 10)
