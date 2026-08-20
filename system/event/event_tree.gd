@icon("res://data/icon/event_tree.svg")
extends Node2D
## Sequential container for scene-authored gameplay events.
##
## Direct BaseEvent children are collected in scene-tree order during _ready().
## Starting the tree locks player movement, changes Game to EVENT, then waits for
## every child to emit BaseEvent.on_event_end before restoring the previous game
## state. EventTrigger and EventComponent nodes must also be direct children when
## they need to discover this tree through their parent.
class_name EventTree

signal on_tree_start
signal on_tree_end
signal on_disable_changed(disabled: bool)

@export var auto_start:bool = false
@export var disable:bool = false:
	set(value):
		if disable == value:
			return
		disable = value
		on_disable_changed.emit(disable)

var event_list:Array[BaseEvent]
var is_running:bool = false

func _ready() -> void:
	if auto_start:
		World.on_level_ready.connect(tree_start)
		
	set_event_list()
	
	
func set_enable_event(enable:bool = true):
	if enable:
		_enable_event()
		
	else:
		_disable_event()
	
func _disable_event():
	disable = true
	visible = false
	
func _enable_event():
	disable = false
	visible = true

## Start the sequence unless the tree is disabled or already running.
func tree_start() -> void:
	if disable or is_running:
		return

	is_running = true
	var previous_state: Game.GAMESTATE = Game.game_state
	World.player.go_static()
	Game.set_game_state(Game.GAMESTATE.EVENT)
	on_tree_start.emit()
	
	for event in event_list:
		event.event()
		await event.on_event_end
	
	on_tree_end.emit()
	World.player.go_move()
	Game.set_game_state(previous_state)
	is_running = false
	
## Rebuild the ordered event list from direct BaseEvent children.
func set_event_list() -> void:
	for child in get_children():
		if child is BaseEvent:
			event_list.append(child)
