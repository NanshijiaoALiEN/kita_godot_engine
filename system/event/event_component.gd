@abstract
extends Node2D
## Base class for visual or behavioral helpers attached to an EventTree.
##
## Components discover their EventTree only when it is their direct parent, then
## receive a component_setup callback for subclass-specific signal wiring.
class_name EventComponent

var event_tree:EventTree

func _ready() -> void:
	if get_parent() is EventTree:
		event_tree = get_parent()
		
	component_setup()

## Configure this component after its optional EventTree parent is resolved.
func component_setup() -> void:
	pass
