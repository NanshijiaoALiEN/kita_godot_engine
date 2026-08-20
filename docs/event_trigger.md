# EventTrigger Usage

`EventTrigger` is an `Area2D` that starts its direct-parent `EventTree` when the
player's `PlayerEventTrigger` enters its collision area.

Source: [`res://system/event/event_trigger.gd`](../system/event/event_trigger.gd)

## Required scene structure

```text
EventTree
├─ EventTrigger
│  └─ CollisionShape2D
├─ EventSprite            # Optional interaction feedback
└─ DialogueEvent          # One or more BaseEvent children
```

The `EventTrigger` must be a direct child of `EventTree`; `_ready()` only checks
its immediate parent. It also needs at least one enabled `CollisionShape2D` or
`CollisionPolygon2D`.

The player scene must contain an `Area2D` using
`res://system/event/player_event_trigger.gd`. The current player scene already
provides this node and rotates it to follow the player's latest movement
direction.

Ensure the collision layers and masks of both areas allow them to detect each
other.

## Trigger modes

### Interaction input

Leave `touch_trigger` disabled for an interaction prompt:

1. The player's sensor enters the area.
2. `can_trigger` becomes `true`.
3. The player presses the `event_trigger` input action.
4. The parent tree receives `tree_start()`.

The project currently maps `event_trigger` to Z and Enter.

### Touch activation

Enable `touch_trigger` to start the parent tree immediately when the player's
sensor enters the area. No interaction button is required.

## Signals and state

- `_on_player_entered`: emitted after a matching player sensor enters.
- `_on_player_exited`: emitted after the player sensor exits.
- `can_trigger`: true while a matching `PlayerEventTrigger` overlaps the area.

These signals are used by `EventSprite` to play its `react`, `ready`, `idle`, and
`trigger` animations. They are implementation-facing signals despite their
leading underscores.

## Setup checklist

1. Add an `EventTree` to a level or actor scene.
2. Add `EventTrigger` directly below it.
3. Add and size a collision shape below the trigger.
4. Configure collision layers and masks to overlap the player's sensor.
5. Choose touch or interaction-input mode.
6. Add one or more `BaseEvent` children directly below the same `EventTree`.
7. Optionally instantiate `res://system/event/event_sprite.tscn` as another
   direct child of the tree.

## Current constraints

- A trigger outside an `EventTree` has no effect.
- The trigger recognizes only areas whose script type is `PlayerEventTrigger`.
- Input mode depends on an existing `event_trigger` action in Project Settings.
- Overlapping triggers from different trees can all receive the same input.
  Each tree's `is_running` lock prevents that tree from starting twice, but does
  not choose between different trees.
- Disabling an `EventTree` prevents execution, but the Area2D can still detect
  entry and exit events.

See also [EventTree Usage](event_tree.md) and
[BaseEvent Usage](base_event.md).
