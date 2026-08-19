extends State

@export var camera:MainCamera

func _on_main_camera_on_camera_follow() -> void:
	transition.emit(self, "FollowState")
