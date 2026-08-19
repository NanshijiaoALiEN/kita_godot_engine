@icon("res://data/icon/event_tree.svg")
extends Node2D
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

func tree_start() -> void:
	if disable:
		return

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
	
func set_event_list() -> void:
	for child in get_children():
		if child is BaseEvent:
			event_list.append(child)
