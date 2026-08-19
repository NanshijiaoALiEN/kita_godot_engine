extends State

@export var camera:MainCamera

func Physics_Update(_delta:float) -> void:
	pass

func _on_main_camera_on_camera_follow() -> void:
	transition.emit(self, "FollowState")
