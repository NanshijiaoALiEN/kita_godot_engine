extends Node
class_name LoopNavGroup

var nav_point_group:Array[LoopNavPoint]

func get_nav_point_group() -> Array[LoopNavPoint]:
	nav_point_group.clear()
	
	for child in get_children():
		if child is LoopNavPoint:
			nav_point_group.append(child)
			
	return nav_point_group
