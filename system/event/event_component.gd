@abstract
extends Node2D
class_name EventComponent

var event_tree:EventTree

func _ready() -> void:
	if get_parent() is EventTree:
		event_tree = get_parent()
		
	component_setup()

func component_setup() -> void:
	pass
