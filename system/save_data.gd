extends Resource
class_name SaveData

# Game Progress
@export var current_level:LevelData
@export var current_level_data:LevelData
@export var last_checkpoint_level:LevelData
@export var player_global_position:Vector2
@export var has_player_global_position:bool = false
@export var global_variables:Dictionary = {}
@export var total_game_time:float = 0.0

# Girl Data
@export var girl_data_list:Array[GiantessData]

@export var game_clear:bool = false
