## Composition root for the running game.
##
## This node receives scene-owned dependencies through exported properties, then
## injects them into the Event, Game, Interface, Sound, and World autoloads. It
## also owns the global pause/title flow. Keep gameplay-specific logic in levels,
## actors, or event nodes instead of adding it here.
extends Node

#World
@export var world_node: Node2D

var current_level:BaseLevel

# Sound
@export var music_player: AudioStreamPlayer
@export var sound_player: AudioStreamPlayer

# Interface
@export var pause_screen: PauseScreen
@export var title_screen: TitleScreen
@export var transition_screen: TransitionScreen 
@export var picture_player:PicturePlayer

# Play Element
var player:Player

func _ready() -> void:
	## Load persistent settings before exposing scene services to the autoloads.
	Game.load_config()
	Game.apply_config()

	World.world_node = world_node
	
	music_player.bus = &"Music"
	sound_player.bus = &"Sound"
	
	Sound.music_player = music_player
	Sound.sound_player = sound_player
	
	Interface.pause_screen = pause_screen
	Interface.title_screen = title_screen
	Interface.transition = transition_screen
	Interface.player = picture_player
	pause_screen.resume_requested.connect(_resume_game)
	pause_screen.title_requested.connect(_return_to_title)
	
	World.player = player
	
	title_screen.open()
	await Interface.transition.fade_out(1.0)
	
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"pause"):
		if !Game.can_pause():
			return
		Game.set_game_state(Game.GAMESTATE.PAUSED)
		get_tree().paused = true
		pause_screen.open()

func _resume_game() -> void:
	pause_screen.close()
	get_tree().paused = false
	Game.set_game_state(Game.GAMESTATE.PLAYING)

func _return_to_title() -> void:
	pause_screen.close()
	get_tree().paused = false
	World._free_level(World.current_level)
	World.current_level = null
	Game.set_game_state(Game.GAMESTATE.TITLE)
	title_screen.open()
