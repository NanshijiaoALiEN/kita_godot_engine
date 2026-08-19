@icon("res://data/icon/change_level_event.svg")
extends BaseEvent
class_name ChangeLevelEvent

@export var level_data:LevelData
@export var spawn_id:String = &"start"

func event() -> void:
	World.switch_level(level_data, spawn_id)
