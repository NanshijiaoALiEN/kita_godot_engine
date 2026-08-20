# EventTree Usage

`EventTree` is a scene-authored sequence controller. It collects direct
`BaseEvent` children in scene-tree order and runs them one at a time.

Source: [`res://system/event/event_tree.gd`](../system/event/event_tree.gd)

## Required environment

`EventTree` uses the project's `World` and `Game` autoloads. Before a sequence
starts, `World.player` must reference a valid `Player`.

The runtime performs the following steps:

1. Reject the request when the tree is disabled or already running.
2. Save the current `Game.game_state`.
3. call `World.player.go_static()` and change the game state to `EVENT`.
4. Emit `on_tree_start`.
5. Call each event's `event()` method and wait for its `on_event_end` signal.
6. Emit `on_tree_end`, restore player movement, and restore the previous game
   state.

## Scene structure

Every event step must be a direct child of the `EventTree`:

```text
Level or Actor
└─ EventTree
   ├─ EventTrigger       # Optional
   │  └─ CollisionShape2D
   ├─ EventSprite        # Optional
   ├─ DialogueEvent      # First event step
   └─ ChangeLevelEvent   # Second event step
```

Only direct children that extend `BaseEvent` are added to the sequence.
`EventTrigger` and `EventComponent` implementations also expect `EventTree` to
be their direct parent.

## Inspector properties

| Property | Default | Behavior |
| --- | --- | --- |
| `auto_start` | `false` | Connects `tree_start()` to `World.on_level_ready`. |
| `disable` | `false` | Prevents the sequence from starting and emits `on_disable_changed` when changed. |

Use `auto_start` for level-opening sequences. The intro level provides the
current project example:

```text
Intro
└─ EventTree (auto_start = true)
   └─ DialogueEvent
```

## Public API

### Signals

- `on_tree_start`: emitted after player movement is locked and before the first
  event runs.
- `on_tree_end`: emitted after every event step completes.
- `on_disable_changed(disabled)`: emitted when `disable` changes.

### Methods

- `tree_start()`: starts the sequence. Repeated calls are ignored while
  `is_running` is true.
- `set_enable_event(enable = true)`: enables or disables the tree and updates
  its visibility.
- `set_event_list()`: scans direct children and appends `BaseEvent` instances to
  the execution list.

To start a tree from another script:

```gdscript
@export var event_tree: EventTree

func begin_cutscene() -> void:
    if event_tree.disable or event_tree.is_running:
        return
    event_tree.tree_start()
    await event_tree.on_tree_end
```

## Current constraints

- The event list is built during `_ready()`. Events added later are not included
  automatically.
- `set_event_list()` does not clear the existing array. Do not call it more than
  once unless the implementation is changed to rebuild the list safely.
- Every event must emit `on_event_end`; otherwise the tree remains locked in its
  running state.
- At completion, the player always enters the move state. The previous player
  state is not restored.
- `ChangeLevelEvent` does not currently emit `on_event_end`; use it only as a
  terminal event whose level is about to be replaced.

See also [BaseEvent Usage](base_event.md) and
[EventTrigger Usage](event_trigger.md).
