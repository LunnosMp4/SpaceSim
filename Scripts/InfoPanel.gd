extends Control

func update_info_panel(planet):
	if planet:
		self.visible = true
		var mass_text = "Mass: " + str(to_scientific_notation(planet.mass / Constants.MASS_SCALE)) + " kg"
		var speed_text = "Speed: " + pad_string(str(snapped(planet.calculate_orbital_speed(planet.orbiting_planet), 0.1)), 1) + " u/s"
		var distance_text = "Distance to Orbit: " + pad_string(str(snapped(planet.global_position.distance_to(planet.orbiting_planet.global_position), 0.1)), 1) + " u"

		get_node("MassLabel").text = mass_text
		get_node("SpeedLabel").text = speed_text
		get_node("DistanceLabel").text = distance_text
		get_node("TypeLabel").text = "Type: " + planet.planet_type
		get_node("NameLabel").text = planet.body_name
		get_node("OrbitingLabel").text = "Orbiting: " + planet.orbiting_planet.body_name
	else:
		self.visible = false

func pad_string(text: String, width: int) -> String:
	return text.pad_decimals(width)

func to_scientific_notation(value: float, max_digits: int = 4) -> String:
	var value_str = str(value)
	var parts = value_str.split(".", false, 1)
	var whole_part = parts[0]
	
	var exponent = whole_part.length() - 1
	
	var formatted_value = whole_part[0] + "." + whole_part.substr(1, max_digits - 1)
	return "%se%s" % [formatted_value, exponent]
