# World Skeleton
extends Node

const DEFAULT_LEVEL = preload("res://level/level_data/default_level.tres")

var current_level:BaseLevel
var current_level_data:LevelData
var suspend_level:BaseLevel

var mini_level_data:LevelData
var is_in_mini_level:bool = false

var world_node:WorldNode

var player:Player
var camera:MainCamera

var is_switching_level:bool = false

signal on_level_ready
signal on_mini_level_entered
signal on_mini_level_exited



## AVAILABLE LEVEL
const ABOVE_CABINET = preload("uid://cenias3ldv44u")
const BELOW_CABINET = preload("uid://baoad5xj55ofs")
const SANAE_FLOOR = preload("uid://d1wn053gxeynn")
const SANAE_FLOOR_BAREFEET = preload("uid://b1pcwe5s4qdvf")
const SANAE_ROOM = preload("uid://beogna0u62p0q")
const SECRET_SHOP = preload("uid://oodh36gx8qvh")
const SHRINE = preload("uid://bdjcl1wxksek6")
const SPIDER_CAVE = preload("uid://dqebr3cscpqbj")
const TOWN_LEVEL = preload("uid://dr01tfwnjqwca")
const SANAE_PANTY = preload("uid://cevh3x3p67r0a")
const SANAE_SANDAL = preload("uid://be7rd238m4kvj")
const ENDING = preload("uid://dgrm1wci62k42")


const GAME_OVER = preload("uid://cce3anu42kunc")

# ENDING
const BOOB_CRUSHED_END = preload("uid://k2xeavc7tqno")
const CLIMB_FAILED_END = preload("uid://ifmdy6yyb67d")
const SANDAL_CRUSH_END = preload("uid://2rtnylm8008i")
const BAREFEET_CRUSH_END = preload("uid://djet6kw7paih3")
const CLIMB_SUCCESS_END = preload("uid://d3fq46pcgsdwr")
const ESCAPE_SANAE = preload("uid://crlfuavnkogv8")

# Switch to the specified level, then set up the spawn point with spawn_id.
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

	var was_in_mini_level := is_in_mini_level
	var loaded := _load_level(level_data.level_path)
	if loaded:
		current_level_data = level_data
		if Game.save_data:
			Game.save_data.current_level_data = current_level_data
			Game.save_data.current_level = current_level_data
		if was_in_mini_level:
			_clear_suspended_level()
			is_in_mini_level = false
		if Game.save_data and level_data.has_checkpoint:
			Game.save_data.last_checkpoint_level = level_data
		_set_up_loaded_level.call_deferred(current_level, spawn_id)
	else:
		await Interface.transition.fade_out(0.5)

	is_switching_level = false
	return loaded

func _set_up_loaded_level(level:BaseLevel, spawn_id:StringName, is_mini_level:bool = false) -> void:
	if !is_instance_valid(level) or level != current_level:
		return

	await level.level_set_up(spawn_id)
	if is_instance_valid(level) and level == current_level:
		if !is_mini_level:
			Game.set_game_state(Game.GAMESTATE.PLAYING)
		on_level_ready.emit()
		if is_mini_level and is_in_mini_level:
			on_mini_level_entered.emit()

func switch_mini_level(level_data:LevelData = null, spawn_id:StringName = &"start") -> bool:
	if is_in_mini_level:
		return await exit_mini_level()

	return await enter_mini_level(level_data, spawn_id)

func return_to_title() -> void:
	await Interface.transition.fade_in(0.5)
	_free_level(World.current_level)
	current_level = null
	Game.set_game_state(Game.GAMESTATE.TITLE)
	Interface.title_screen.open()
	await Interface.transition.fade_out(0.5)
	return

func enter_mini_level(level_data:LevelData = null, spawn_id:StringName = &"start") -> bool:
	if is_switching_level:
		return false
	if is_in_mini_level:
		return false
	if !level_data:
		level_data = mini_level_data
	if !level_data or level_data.level_path.is_empty():
		push_error("Invalid mini level data.")
		return false
	if !is_instance_valid(current_level):
		push_error("Cannot enter mini level: current level is not ready.")
		return false
	if !world_node or !Interface.transition:
		push_error("World is not ready.")
		return false

	is_switching_level = true
	await Interface.transition.fade_in(0.5)

	suspend_level = current_level
	if suspend_level.get_parent():
		suspend_level.get_parent().remove_child(suspend_level)

	var loaded := _load_level(level_data.level_path, false, "mini level")
	if loaded:
		mini_level_data = level_data
		is_in_mini_level = true
		_set_up_loaded_level.call_deferred(current_level, spawn_id, true)
	else:
		_restore_suspended_level()
		await Interface.transition.fade_out(0.5)

	is_switching_level = false
	return loaded

func exit_mini_level() -> bool:
	if is_switching_level:
		return false
	if !is_in_mini_level:
		return false
	if !is_instance_valid(suspend_level):
		push_error("Cannot exit mini level: suspended level is not available.")
		return false
	if !world_node or !Interface.transition:
		push_error("World is not ready.")
		return false

	is_switching_level = true
	await Interface.transition.fade_in(0.5)

	_free_level(current_level)

	_restore_suspended_level()
	_resume_current_level()
	is_in_mini_level = false
	await Interface.transition.fade_out(0.5)
	on_mini_level_exited.emit()

	is_switching_level = false
	return true

func game_over_level() -> void:
	await Interface.player.remove_all_picture(1.0)
	await switch_level(GAME_OVER)
	return

func _resume_current_level() -> void:
	if !is_instance_valid(current_level):
		return

	player = current_level.player
	camera = current_level.camera

	if player:
		player.show()

	if camera:
		camera.follow_target = player
		camera.enabled = true
		camera.limit()
		camera.reset_smoothing()
		camera.camera_follow()

func set_player_position(position:Vector2) -> void:
	if !is_instance_valid(player):
		return

	player.global_position = position
	if camera:
		camera.global_position = position
		camera.reset_smoothing()
		camera.camera_follow()

func _restore_suspended_level() -> void:
	current_level = suspend_level
	suspend_level = null
	if is_instance_valid(current_level) and !current_level.get_parent():
		world_node.add_child(current_level)

func _clear_suspended_level() -> void:
	_free_level(suspend_level)
	suspend_level = null


# Load a new level scene and discard the current level.
func _load_level(level_path:String, free_current_level:bool = true, level_label:String = "level") -> bool:
	var level_resource := ResourceLoader.load(level_path)
	if !(level_resource is PackedScene):
		push_error("Failed to load %s: %s" % [level_label, level_path])
		return false

	var new_level:BaseLevel = level_resource.instantiate()
	if !(new_level is BaseLevel):
		new_level.queue_free()
		push_error("%s is not a BaseLevel: %s" % [level_label.capitalize(), level_path])
		return false

	if free_current_level:
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
