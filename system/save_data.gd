extends Resource
## Serializable snapshot written to a numbered user:// save slot by Game.
##
## It stores portable Resources and values only; scene instances are recreated by
## World and BaseLevel when loading.
class_name SaveData

# Game Progress
@export var current_level:LevelData
@export var current_level_data:LevelData
@export var last_checkpoint_level:LevelData
@export var global_variables:Dictionary = {}

@export var game_clear:bool = false
