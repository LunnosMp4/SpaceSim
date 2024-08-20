extends Control

var planet = null

@onready var SelectPanel = $SelectPanel
@onready var SelectedLabel = $SelectPanel/SelectedBody

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

func _ready():
	self.visible = false
	var planet_scene = planets["Terran Wet"] # default planet
	planet = planet_scene.instantiate()
	planet.set_position(Vector2(40, 50))
	planet.set_light(Vector2(0.3, 0.5))
	SelectPanel.add_child(planet)

func update_visibility(active):
	self.visible = active

func update_selected_body(body_type):
	SelectedLabel.text = body_type
	planet.queue_free()
	planet = planets[body_type].instantiate()
	planet.set_position(Vector2(40, 50))
	planet.set_light(Vector2(0.3, 0.5))
	SelectPanel.add_child(planet)
