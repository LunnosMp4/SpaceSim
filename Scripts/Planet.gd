extends RigidBody2D

const G = 6.67430e-16

var custom_mass = 5.972e24
var initial_velocity = Vector2()
var last_force = Vector2()
var position_history = []
var is_colliding = false
var planet_type = "Terran Wet"
var sun_global_position = Vector2()

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
	planet.randomize_colors()
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
			if is_colliding and body.mass > self.mass:
				queue_free()

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

# Fonction pour normaliser la position de la lumière
func normalize_light_position(position: Vector2) -> Vector2:
	var max_distance = 1e3
	var normalized_position = position / max_distance  # Divisez par la distance maximale
	normalized_position.x = clamp(normalized_position.x, 0, 1)  # Assurez-vous que la valeur est entre 0 et 1
	normalized_position.y = clamp(normalized_position.y, 0, 1)  # Assurez-vous que la valeur est entre 0 et 1
	print(normalized_position)
	return normalized_position

func set_sun_position(position: Vector2):
	sun_global_position = position

func update_light_position():
	var light_position = normalize_light_position(sun_global_position - global_position)
	for planet in get_children():
		if planet.has_method("set_light"):
			planet.set_light(light_position)

func _on_body_entered(body):
	is_colliding = true

func _on_body_exited(body):
	is_colliding = false

func get_custom_mass():
	return custom_mass
