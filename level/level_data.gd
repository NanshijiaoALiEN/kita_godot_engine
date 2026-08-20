extends Resource
## Serializable catalog entry for a loadable level.
##
## World loads [member level_path] and requires that scene's root to extend
## [BaseLevel]. The remaining fields provide UI metadata and checkpoint policy.
class_name LevelData

@export var level_name:String
@export_file("*png") var level_thumbnail:String
@export_multiline("level_info") var level_info:String
@export_file("*tscn") var level_path:String
@export var has_checkpoint:bool = true
