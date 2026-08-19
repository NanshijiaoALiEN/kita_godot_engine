@icon("res://data/icon/dialogue_event.svg")
extends BaseEvent
class_name DialogueEvent

@export var dialogue:DialogueResource
@export var title:String = "start"

func event() -> void:
	on_event_start.emit()
	await Event.dialogue_event(dialogue, title.to_lower())
	on_event_end.emit()
	return
