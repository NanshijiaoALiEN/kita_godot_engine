## GLOBAL
extends Node



func get_variables() -> Dictionary:
	var data := {}

	for property in get_property_list():
		var usage: int = property.get("usage")
		var prop_name: String = property.get("name")

		if (usage & PROPERTY_USAGE_SCRIPT_VARIABLE) != 0:
			data[prop_name] = get(prop_name)

	return data

func set_variables(data:Dictionary) -> void:
	var valid_variables := get_variables()
	for prop_name in data:
		if valid_variables.has(prop_name):
			set(prop_name, data[prop_name])
