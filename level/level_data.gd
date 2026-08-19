extends Resource
class_name LevelData

@export var level_name:String
@export_file("*png") var level_thumbnail:String
@export_multiline("level_info") var level_info:String
@export_file("*tscn") var level_path:String
@export var has_checkpoint:bool = true
