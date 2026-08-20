@icon("res://data/icon/main_camera.svg")
extends Camera2D
## Level camera with bounds, target-follow signals, tweened moves, zoom, and shake.
##
## Each BaseLevel must expose a MainCamera child. The boundary markers are used by
## [method limit] to convert authored scene positions into Camera2D limits.
class_name MainCamera

@export var follow_target:Node2D

@export_group("Camera Shake")
@export var noise:Noise
@export_range(0.0, 2.0) var trauma:float = 0.0
@export var shake_max_x:float = 50.0
@export var shake_max_y:float = 30.0
@export var shake_max_r:float = 0.005

@export var top_right_marker:Marker2D
@export var bottom_left_marker:Marker2D

var time:float

signal on_camera_move
signal on_camera_zoom
signal on_camera_follow
signal on_camera_shake

var origin_zoom:float


func _physics_process(delta: float) -> void:
	time += delta
	var shake:float = pow(trauma, 2.0)
	offset.x = noise.get_noise_3d(time * 100.0, 0, 0) * shake_max_x * shake
	offset.y = noise.get_noise_3d(0, time * 100.0, 0) * shake_max_y * shake

## Apply camera limits from the authored top-right and bottom-left markers.
func limit():
	limit_top = int(top_right_marker.global_position.y)
	limit_bottom = int(bottom_left_marker.global_position.y)
	limit_right = int(top_right_marker.global_position.x)
	limit_left = int(bottom_left_marker.global_position.x)
	
## Notify the camera scene's connected follow behavior to resume tracking.
func camera_follow():
	on_camera_follow.emit()

func camera_move(target:Node2D, duration:float = 1.0) -> void:
	on_camera_move.emit()
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "global_position", target.global_position, duration)
	await tween.finished
	return
	
func camera_zoom(value:float = 1.0, duration:float = 1.0) -> void:
	origin_zoom = zoom.x
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "zoom", Vector2(value, value), duration)
	await tween.finished
	return
	
func reset_camera_zoom(duration:float = 1.0) -> void:
	camera_zoom(origin_zoom, duration)
	
func camera_shake(strength:float = 1.0, duration:float = 1.0) -> void:
	on_camera_shake.emit()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "trauma", strength, duration/4)
	tween.tween_property(self, "trauma", strength, duration/2)
	tween.tween_property(self, "trauma", 0.0, duration/4)
	await tween.finished
	return
