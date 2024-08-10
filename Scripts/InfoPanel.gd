extends Control

func update_info_panel(planet):
	if planet:
		get_node("MassLabel").text = "Mass: " + str(to_scientific_notation(planet.mass)) + " kg"
		get_node("SpeedLabel").text = "Speed: " + str(snapped(planet.calculate_orbital_speed(planet.orbiting_planet), 0.01)) + " units/s"
		get_node("DistanceLabel").text = "Distance to Orbit: " + str(snapped(planet.global_position.distance_to(planet.orbiting_planet.global_position), 0.01)) + " units"
		get_node("TypeLabel").text = "Type: " + planet.planet_type
		get_node("NameLabel").text = "Name: " + planet.body_name
		get_node("OribitingLabel").text = "Orbiting: " + planet.orbiting_planet.body_name
	else:
		get_node("MassLabel").text = ""
		get_node("SpeedLabel").text = ""
		get_node("DistanceLabel").text = ""
		get_node("TypeLabel").text = ""
		get_node("NameLabel").text = ""
		get_node("OribitingLabel").text = ""

func to_scientific_notation(value: float, max_digits: int = 4) -> String:
	var value_str = str(value)
	var parts = value_str.split(".", false, 1)
	var whole_part = parts[0]
	
	var exponent = whole_part.length() - 1
	
	var formatted_value = whole_part[0] + "." + whole_part.substr(1, max_digits - 1)
	return "%se%s" % [formatted_value, exponent]
