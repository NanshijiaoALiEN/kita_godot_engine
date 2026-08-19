extends Resource
class_name GiantessData

@export var character_data:CharacterData
@export var stomp_game_level:LevelData

## Use for Nav State
@export var max_speed:float = 60.0
@export var run_speed:float = 100.0
@export var acceleration:float = 20.0
@export var friction:float = 40.0

@export var related_end_scene:Array[LevelData]