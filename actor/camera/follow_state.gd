extends State

@export var camera:MainCamera

func Physics_Update(_delta:float) -> void:
	camera.global_position = World.player.global_position

func _on_main_camera_on_camera_move() -> void:
	transition.emit(self, "MoveState")
