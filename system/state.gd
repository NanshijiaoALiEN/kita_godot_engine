extends Node
## Extension point for StateMachine behavior.
##
## Subclasses override lifecycle/update methods and emit [signal transition] with
## their own instance plus the target state's child-node name.
class_name State

signal transition(state:State, new_state_name:String)

## Called when this state becomes active.
func Enter() -> void:
	pass
	
## Called immediately before another state becomes active.
func Exit() -> void:
	pass
	
## Called from StateMachine._physics_process while this state is active.
func Physics_Update(_delta:float) -> void:
	pass
	
## Called from StateMachine._process while this state is active.
func Update(_delta:float) -> void:
	pass
	
	
