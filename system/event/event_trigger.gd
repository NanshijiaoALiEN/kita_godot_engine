extends Area2D
## Interaction area that starts its direct-parent EventTree.
##
## The area reacts only to PlayerEventTrigger. In touch mode entry starts the tree
## immediately; otherwise entry enables the project input action event_trigger.
## Add one or more CollisionShape2D children in the authored scene.
class_name EventTrigger

@export var touch_trigger:bool = false

var event_tree:EventTree
## True while a PlayerEventTrigger overlaps this interaction area.
var can_trigger:bool = false

signal _on_player_entered
signal _on_player_exited

func _ready() -> void:
	if get_parent() is EventTree:
		event_tree = get_parent()
		
	if event_tree:
		area_entered.connect(_on_area_entered)
		area_exited.connect(_on_area_exited)
		
func _on_area_entered(area:Area2D):
	if area is PlayerEventTrigger:
		if touch_trigger:
			event_tree.tree_start()
		
		can_trigger = true
		_on_player_entered.emit()
	
func _on_area_exited(area:Area2D):
	if area is PlayerEventTrigger:
		can_trigger = false
		_on_player_exited.emit()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"event_trigger") and can_trigger and event_tree and !touch_trigger:
		event_tree.tree_start()
