## Global game state, save-slot, and user-configuration service.
##
## Save files are Resources stored under user://. Level restoration is delegated
## to World so the same loading pipeline is used for new games and loaded saves.
## Systems that temporarily change [member game_state] should restore the state
## they observed before starting.
extends Node

enum GAMESTATE {
	TITLE,
	PLAYING,
	PAUSED,
	DIALOGUE,
	EVENT,
	TRANSITION,
}

var save_data:SaveData
var config_data:ConfigData
const MAX_SAVE_SLOTS:int = 10
const CONFIG_PATH:String = "user://config_data.tres"
const MIN_VOLUME_DB:float = -80.0

var current_slot:int = 0

var game_state:GAMESTATE = GAMESTATE.TITLE
var previous_game_state:GAMESTATE = GAMESTATE.TITLE

signal on_game_saved
signal on_game_loaded
signal on_game_state_changed(game_state:GAMESTATE)

func new_game() -> void:
	save_data = SaveData.new()
	current_slot = 0
	
## Persist the current level and global variables.
## Only existing slots or the next free sequential slot may be written.
func save_game(slot:int) -> bool:
	if slot < 1 or slot > MAX_SAVE_SLOTS:
		return false
	if !has_save(slot) and slot != get_next_save_slot():
		return false

	if !save_data:
		save_data = SaveData.new()

	save_data.current_level_data = World.current_level_data
	save_data.current_level = World.current_level_data
	save_data.global_variables = Global.get_variables()

	if ResourceSaver.save(save_data, _get_save_path(slot)) == OK:
		current_slot = slot
		on_game_saved.emit()
		return true
	return false
		
## Restore a save resource, then ask World to load its recorded level.
func load_game(slot:int) -> bool:
	if !has_save(slot):
		return false

	var loaded_data := ResourceLoader.load(_get_save_path(slot), "", ResourceLoader.CACHE_MODE_IGNORE) as SaveData
	if !loaded_data:
		return false

	save_data = loaded_data
	current_slot = slot
	_restore_save_data()
	on_game_loaded.emit()
	if save_data.current_level_data:
		return await World.switch_level(save_data.current_level_data)
	return true

func has_save(slot:int) -> bool:
	return slot >= 1 and slot <= MAX_SAVE_SLOTS and FileAccess.file_exists(_get_save_path(slot))

func get_save_slots() -> Array[int]:
	var slots:Array[int] = []
	for slot in range(1, MAX_SAVE_SLOTS + 1):
		if get_save_data(slot):
			slots.append(slot)
	return slots

func get_next_save_slot() -> int:
	for slot in range(1, MAX_SAVE_SLOTS + 1):
		if !has_save(slot):
			return slot
	return 0

func get_save_data(slot:int) -> SaveData:
	if !has_save(slot):
		return null
	return ResourceLoader.load(_get_save_path(slot), "", ResourceLoader.CACHE_MODE_IGNORE) as SaveData

func load_config() -> void:
	config_data = ResourceLoader.load(CONFIG_PATH, "", ResourceLoader.CACHE_MODE_IGNORE) as ConfigData
	if !config_data:
		config_data = ConfigData.new()
	
func save_config() -> void:
	if !config_data:
		config_data = ConfigData.new()
	ResourceSaver.save(config_data, CONFIG_PATH)
	
func apply_config() -> void:
	if !config_data:
		return
	_set_bus_volume(&"Master", config_data.master_volume)
	_set_bus_volume(&"Music", config_data.music_volume)
	_set_bus_volume(&"Sound", config_data.sound_volume)

func _set_bus_volume(bus_name:StringName, volume:float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index >= 0:
		AudioServer.set_bus_volume_db(bus_index, MIN_VOLUME_DB if volume <= 0.0 else linear_to_db(volume))


func _get_save_path(slot:int) -> String:
	return "user://save_data_%d.tres" % slot

## Change the global state and notify listeners only when the value changed.
func set_game_state(state:GAMESTATE) -> void:
	if game_state == state:
		return

	previous_game_state = game_state
	game_state = state
	on_game_state_changed.emit(game_state)

func is_playing() -> bool:
	return game_state == GAMESTATE.PLAYING

func can_pause() -> bool:
	return game_state == GAMESTATE.PLAYING
	
func pause_game() -> void:
	pass

func _restore_save_data() -> void:
	if !save_data.current_level_data:
		save_data.current_level_data = save_data.current_level
	Global.set_variables(save_data.global_variables)
	
