## Runtime owner of level loading, the active player, and the active camera.
##
## Root injects [member world_node], while each [BaseLevel] supplies its player
## and camera during setup. Level switches discard the current level before the
## newly instantiated level is configured at its requested spawn point.
extends Node

var current_level:BaseLevel
var current_level_data:LevelData

var world_node:WorldNode

var player:Player
var camera:MainCamera

var is_switching_level:bool = false

signal on_level_ready

const DEFAULT_LEVEL = preload("res://level/level_data/default_level.tres")
const GAME_OVER = preload("uid://cce3anu42kunc")

## Fade out, instantiate the requested [BaseLevel], and defer its spawn setup.
## Returns false when a switch is already running or the level cannot be loaded.
func switch_level(level_data:LevelData, spawn_id:StringName = &"start") -> bool:
	if is_switching_level:
		return false
	if !level_data or level_data.level_path.is_empty():
		push_error("Invalid level data.")
		return false
	if !world_node or !Interface.transition:
		push_error("World is not ready.")
		return false

	is_switching_level = true
	await Interface.transition.fade_in(0.5)

	var loaded := _load_level(level_data.level_path)
	if loaded:
		current_level_data = level_data
		if Game.save_data:
			Game.save_data.current_level_data = current_level_data
			Game.save_data.current_level = current_level_data
		if Game.save_data and level_data.has_checkpoint:
			Game.save_data.last_checkpoint_level = level_data
		_set_up_loaded_level.call_deferred(current_level, spawn_id)
	else:
		await Interface.transition.fade_out(0.5)

	is_switching_level = false
	return loaded

func _set_up_loaded_level(level:BaseLevel, spawn_id:StringName) -> void:
	if !is_instance_valid(level) or level != current_level:
		return

	await level.level_set_up(spawn_id)
	if is_instance_valid(level) and level == current_level:
		Game.set_game_state(Game.GAMESTATE.PLAYING)
		on_level_ready.emit()

func return_to_title() -> void:
	await Interface.transition.fade_in(0.5)
	_free_level(World.current_level)
	current_level = null
	Game.set_game_state(Game.GAMESTATE.TITLE)
	Interface.title_screen.open()
	await Interface.transition.fade_out(0.5)
	return

func game_over_level() -> void:
	await Interface.player.remove_all_picture(1.0)
	await switch_level(GAME_OVER)
	return

func set_player_position(position:Vector2) -> void:
	if !is_instance_valid(player):
		return

	player.global_position = position
	if camera:
		camera.global_position = position
		camera.reset_smoothing()
		camera.camera_follow()

## Instantiate a level scene and verify that its root is a [BaseLevel].
func _load_level(level_path:String) -> bool:
	var level_resource := ResourceLoader.load(level_path)
	if !(level_resource is PackedScene):
		push_error("Failed to load level: %s" % level_path)
		return false

	var new_level:BaseLevel = level_resource.instantiate()
	if !(new_level is BaseLevel):
		new_level.queue_free()
		push_error("Level is not a BaseLevel: %s" % level_path)
		return false

	_free_level(current_level)

	current_level = new_level as BaseLevel
	world_node.add_child(current_level)
	return true

func _free_level(level:BaseLevel) -> void:
	if !is_instance_valid(level):
		return

	if level.get_parent():
		level.get_parent().remove_child(level)
	level.queue_free()
