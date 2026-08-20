# BaseEvent Usage

`BaseEvent` defines one ordered, asynchronous step inside an `EventTree`.
Create subclasses for dialogue, animation, movement, sound, transitions, or any
other operation that must participate in an event sequence.

Source: [`res://system/event/base_event.gd`](../system/event/base_event.gd)

## Contract

A usable subclass must:

1. Override `event()`.
2. Optionally emit `on_event_start` before beginning work.
3. Perform or await its work.
4. Emit `on_event_end` exactly once when the next event may start.

`EventTree` calls `event()` and then waits for `on_event_end`. If the end signal
is never emitted, the entire sequence remains blocked.

## Asynchronous event example

An event that waits for an animation can be implemented as follows:

```gdscript
extends BaseEvent
class_name PlayAnimationEvent

@export var animation_player: AnimationPlayer
@export var animation_name: StringName

func event() -> void:
    on_event_start.emit()
    animation_player.play(animation_name)
    await animation_player.animation_finished
    on_event_end.emit()
```

Place the node directly under an `EventTree`. Its position among the other
`BaseEvent` children determines when it runs.

## Immediate event example

With the current `EventTree` implementation, do not emit `on_event_end`
synchronously before `event()` returns. The tree starts waiting only after the
method call, so it can miss a signal emitted during that call. Defer completion
by at least one frame for an otherwise immediate event:

```gdscript
extends BaseEvent
class_name SetPropertyEvent

@export var target: Node
@export var property_name: StringName
@export var value: Variant

func event() -> void:
    on_event_start.emit()
    target.set(property_name, value)
    await get_tree().process_frame
    on_event_end.emit()
```

## Existing implementations

- `DialogueEvent` waits for the global dialogue helper and then emits
  `on_event_end`.
- `ChangeLevelEvent` requests a level switch but does not currently emit
  completion. Treat it as a terminal event.

## Design guidance

- Keep an event focused on one action so scene order remains readable.
- Put reusable configuration in exported properties rather than hard-coding a
  particular level or actor.
- Always decide what completion means before emitting `on_event_end`.
- Do not call the next event directly. Sequence ownership belongs to
  `EventTree`.
- If an operation can fail, still emit `on_event_end` after reporting or handling
  the failure unless intentionally blocking the sequence is desired.

See also [EventTree Usage](event_tree.md) and
[EventTrigger Usage](event_trigger.md).
