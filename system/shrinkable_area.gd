extends Area2D
class_name ShrinkableArea

@export var mini_level_data:LevelData

func _ready() -> void:
	self.area_entered.connect(on_area_entered)
	self.area_exited.connect(on_area_exited)
		
func on_area_entered(area:Area2D):
	if area is PlayerEventTrigger and mini_level_data:
		World.mini_level_data = mini_level_data
	
func on_area_exited(area:Area2D):
	if area is PlayerEventTrigger and mini_level_data:
		pass
