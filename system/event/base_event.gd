@abstract
extends Node
## Base contract for one asynchronous step in an EventTree sequence.
##
## Implementations should emit on_event_start, perform or await their work, and
## always emit on_event_end. EventTree cannot advance when the end signal is not
## emitted. BaseEvent nodes are ordered by their position under EventTree.
class_name BaseEvent

signal on_event_start
signal on_event_end

## Execute this event step. Subclasses are responsible for completion signals.
func event():
	pass
