extends RigidBody2D

var body_name = "Default"
var custom_mass = null
var initial_velocity = Vector2()
var last_force = Vector2()
var is_colliding = false
var planet_type = "Terran Wet"
var target_scale = Vector2(1, 1)
var orbiting_planet = null  # The planet this body is orbiting around

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
	"Star": preload("res://Planets/Star/Star.tscn"),
}

var densities = {
	"Terran Wet": 5514,
	"Terran Dry": 3933,
	"Islands": 5200,
	"No atmosphere": 3340,
	"Gas giant 1": 1326,
	"Gas giant 2": 700,
	"Ice World": 1600,
	"Lava World": 4100,
	"Asteroid": 2000,
	"Star": 1408,
}

var batch_size = 10  # Number of planets to process per frame
var current_batch_start = 0

func _ready():
	self.mass = custom_mass
	calculate_scale_based_on_mass_and_type()
	scale_visual_and_collision()

	var planet_scene = planets[planet_type]
	var planet = planet_scene.instantiate()
	planet.set_global_position(Vector2(-50, -50))
	var rng = RandomNumberGenerator.new()
	var random_seed = rng.randi()
	planet.set_seed(random_seed)
	planet.randomize_colors()
	add_child(planet)
	add_to_group("planets")
	print("Planet ready with mass: ", custom_mass)
	apply_central_impulse(initial_velocity)

func _physics_process(_delta):
	self.scale = target_scale
	var bodies = get_tree().get_nodes_in_group("planets")
	var strongest_force = 0.0
	orbiting_planet = null 

	for i in range(current_batch_start, min(current_batch_start + batch_size, bodies.size())):
		var body = bodies[i]
		if body != self:
			check_collision_proximity(body)
			var force_magnitude = apply_gravity(body, _delta)
			if force_magnitude > strongest_force:
				strongest_force = force_magnitude
				orbiting_planet = body

	var is_most_massive = true
	for body in bodies:
		if body != self and body.mass > self.mass:
			is_most_massive = false
			break

	if is_most_massive:
		orbiting_planet = self

	current_batch_start += batch_size
	if current_batch_start >= bodies.size():
		current_batch_start = 0

func apply_gravity(body, _delta) -> float:
	if body is RigidBody2D:
		var direction = body.global_position - global_position
		var distance_squared = direction.length_squared()
		if distance_squared < 0.1:
			distance_squared = 0.1  # Avoid division by zero and extreme forces
		if body.has_method("get_custom_mass"):
			var body_mass = body.get_custom_mass()
			var force_magnitude = Constants.G * (custom_mass * body_mass) / distance_squared
			var force = direction.normalized() * force_magnitude
			apply_force(force * _delta, Vector2())  # Apply continuous force
			last_force = force  # Store the last applied force for debug drawing
			return force_magnitude  # Return the force magnitude for orbit calculation
	return 0.0

func check_collision_proximity(body):
	if body is RigidBody2D:
		var combined_radius = get_radius() + body.get_radius()
		var distance = global_position.distance_to(body.global_position)
		
		if distance < combined_radius:
			handle_collision(body)

func get_radius():
	return target_scale.x * 50

func handle_collision(body):
	if body.mass > self.mass:
		queue_free()

func scale_visual_and_collision():
	for child in get_children():
		if child is CollisionShape2D:
			child.scale = target_scale

func calculate_scale_based_on_mass_and_type():
	var density = densities[planet_type] * Constants.MASS_SCALE
	var volume = custom_mass / density
	var radius = pow((3 * volume) / (4 * PI), 1.0 / 3.0)
	target_scale = Vector2(radius, radius) / 10000000

func calculate_orbital_speed(planet) -> float:
	if planet is RigidBody2D:
		var r = global_position.distance_to(planet.global_position)  # Distance in km (assuming your units are km)
		if r > 0:
			var M = planet.get_custom_mass()  # Mass in kg
			var orbital_speed = sqrt(Constants.G * M / r)  # Speed in km/s
			return orbital_speed
	return 0.0

func get_custom_mass():
	return custom_mass

func get_current_velocity():
	return linear_velocity
