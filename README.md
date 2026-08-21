# Kita Godot Project

Kita Godot Project is a Godot Engine template created by Kitamiya for developers who are familiar with RPG Maker and want to learn Godot. It provides familiar RPG-style systems and reusable components to help you build a game quickly.

## Features

### Event System

Create RPG Maker-like events directly in Godot scenes with reusable components:

- **EventTree** runs event steps in sequence.
- **BaseEvent** is the foundation for creating custom event actions.
- **EventTrigger** starts an event through player interaction or touch.
- **EventSprite** displays visual feedback for an event's idle, ready, and triggered states.

Dialogue and level-change event components are also included.

### Player

The Player is designed to feel familiar to RPG Maker users. It supports both **top-down** and **platformer** movement modes and can use character sprites exported from RPG Maker.

### Main Camera

The Main Camera provides `camera_move()`, `camera_shake()`, `camera_follow()`, and `camera_zoom()` functions for creating camera movement and cutscenes. Camera limits and zoom reset support are also included.

### Picture Player

The interface includes a Picture Player inspired by RPG Maker's **Show Picture** command. It can show and remove images with fades, position them around the screen, and scroll tall images vertically.

### Dialogue System

The project includes the [Dialogue Manager](https://github.com/nathanhoad/godot_dialogue_manager) addon, making it easy to create RPG Maker-like conversations and use them as steps in the Event System.

### Sound

The global Sound service provides music playback with fade-in and fade-out, music volume transitions, mapped one-shot sound effects, and runtime audio-resource loading. Music and sound effects use separate audio buses.

### Game

The global Game service manages common game states such as title, playing, paused, dialogue, event, and transition. It also provides up to 10 save slots, level and global-variable restoration, persistent user configuration, and Master, Music, and Sound volume settings.

## Getting Started

1. Open the project with **Godot 4.7**.
2. Run the main scene.
3. Explore the example levels, player scenes, and `system/event` components.
4. Add your own events by placing `BaseEvent` components under an `EventTree` in the order they should run.

## Main Folders

- `actor/` — player, NPC, sprite, and camera components
- `interface/` — menus, transitions, and the Picture Player
- `level/` — levels and level data
- `system/event/` — the RPG Maker-like Event System
- `skeleton/` — global services such as Game, Sound, World, and Interface
- `dialogue/` — Dialogue Manager resources

## Asset Sources

- [Kenney Assets](https://kenney.nl/)
- [Dialogue Manager](https://github.com/nathanhoad/godot_dialogue_manager)

Code is licensed under the MIT License.

Game assets, including artwork, music, sound effects, and other media,
are not covered by the MIT License unless otherwise stated.