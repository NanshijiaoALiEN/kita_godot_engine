## GLOBAL
extends Node


## Town
var did_start_dialogue:bool = false
var town_all_event_passed:bool = false


## Secret Shop Level
var has_entered_secret_shop:bool = false
#var first_time_enter_shop:bool = false
var has_shopper_speak:bool = false
#var first_time_left_shop:bool = false
var has_left_shop:bool = false
#var shopper_give_item:bool = false
var is_shopper_gave_item:bool = false
#var leave_the_shop:bool = false

## Shrine
var shrine_encounter:bool = false

## Sanae Room
var escape_sanae:bool = false
var first_climb_sandal:bool = false
var first_barefeet_closeup:bool = true

## Spider Cave
#var entered_the_holo:bool = false
var has_entered_cave:bool = false
var is_spider_talked:bool = false

var sanae_in_room:bool = false
var first_sandal_travel:bool = true
var is_climbing_sandal:bool = false

## Sanae Panty
var sanae_panty:bool = false
var is_climbing_panty:bool = false


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
