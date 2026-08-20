extends Node2D
## Base class and setup contract for loadable level scenes.
##
## A level must contain MainCamera, Player, and SpawnPointGroup children. Spawn
## points are selected by a case-insensitive match between their node name and
## the spawn_id passed by World. Setup publishes the player/camera to World,
## positions them, starts optional presentation, then starts player control.
class_name BaseLevel

var player:Player
var spawn_point_group:Array[SpawnPoint]
var camera:MainCamera

@export var start_black:bool = false
@export var start_dialogue:bool = false
@export var dialogue:DialogueResource
@export var title:String = "start"

@export var start_playing_music:bool = true
@export var level_music:AudioStream

func _ready() -> void:
	if get_node_or_null(^"MainCamera") is MainCamera:
		camera = get_node_or_null(^"MainCamera")
	
	if get_node_or_null(^"Player") is Player:
		player = get_node_or_null(^"Player")
	
	var spawn_group := get_node_or_null(^"SpawnPointGroup")
	if !spawn_group:
		push_error("BaseLevel requires a SpawnPointGroup child node.")
		return
	
	for node in spawn_group.get_children():
		if node is SpawnPoint:
			spawn_point_group.append(node)
			
	assert(camera)
	assert(player)
	assert(spawn_point_group)

## Resolve the requested spawn, configure World references, and start the level.
func level_set_up(spawn_id:StringName = &"start") -> void:
	if !camera:
		push_error("BaseLevel setup failed: MainCamera is not available.")
		return
	
	var spawn:SpawnPoint
	
	for spawn_point in spawn_point_group:
		if spawn_point.name.to_lower() == spawn_id.to_lower():
			spawn = spawn_point
			break
			
	if !spawn:
		push_error("BaseLevel setup failed: spawn point not found: %s" % spawn_id)
		return

	var player_position := spawn.global_position
	if Game.was_loaded_from_save:
		# The saved position is used only for the first level entered after loading.
		Game.was_loaded_from_save = false
		if Game.save_data and Game.save_data.has_player_global_position:
			player_position = Game.save_data.player_global_position
			
	World.camera = camera
	World.camera.enabled = true
	World.camera.limit()
	
	World.player = player
	World.player.global_position = player_position
	World.camera.global_position = player_position
	World.camera.follow_target = World.player
	World.camera.reset_smoothing()
	World.camera.camera_follow()
	if !start_black:
		Interface.transition.fade_out(0.5)
	
	level_start.call_deferred()

func level_start():
	if start_playing_music and level_music:
		Sound.play_music(level_music)
	
	if dialogue and title and start_dialogue:
		await Event.dialogue_event(dialogue, title)
		
	World.player.start()
	return
		
