@icon("res://data/icon/change_level_event.svg")
extends BaseEvent
## Event step that requests a World level switch.
##
## The current implementation does not await the switch or emit on_event_end, so
## use it only as a terminal step whose containing level will be replaced.
class_name ChangeLevelEvent

@export var level_data:LevelData
@export var spawn_id:String = &"start"

func event() -> void:
	World.switch_level(level_data, spawn_id)
