extends Control
class_name PicturePlayer

enum POSITION {
	UP,
	DOWN,
	LEFT,
	RIGHT
}


const PICTURES_DIR = "res://pictures"

var _pictures: Dictionary[String, TextureRect] = {}


func show_picture(picture_name: String, fade_in_time: float = 1.0, position: POSITION = POSITION.DOWN) -> void:
	var path: String = _find_picture(picture_name)
	if path.is_empty():
		push_warning("Picture not found: %s" % picture_name)
		return

	if _pictures.has(picture_name):
		_pictures[picture_name].queue_free()

	var picture: TextureRect = TextureRect.new()
	picture.texture = load(path)
	var texture_size: Vector2 = picture.texture.get_size()
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.size = Vector2(size.x, size.x * texture_size.y / texture_size.x)
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	picture.modulate.a = 0.0
	add_child(picture)
	picture.set_anchors_and_offsets_preset(_preset_for(position), Control.PRESET_MODE_KEEP_SIZE)
	_pictures[picture_name] = picture
	var tween = create_tween()
	tween.tween_property(picture, "modulate:a", 1.0, maxf(fade_in_time, 0.0))
	await tween.finished
	return

func remove_picture(picture_name: String, fade_out_time: float = 1.0) -> void:
	var picture: TextureRect = _pictures.get(picture_name)
	if not is_instance_valid(picture):
		return
	_pictures.erase(picture_name)
	var tween = create_tween()
	tween.tween_property(picture, "modulate:a", 0.0, maxf(fade_out_time, 0.0)).finished.connect(picture.queue_free)
	await tween.finished
	return

func remove_all_picture(fade_out_time: float = 1.0) -> void:
	for picture_name: String in _pictures.keys():
		remove_picture(picture_name, fade_out_time)
	
	await get_tree().create_timer(fade_out_time).timeout
	return
	

func move_to_top(picture_name: String, duration: float = 4.0) -> void:
	_move_picture(picture_name, false, duration)


func move_to_bottom(picture_name: String, duration: float = 4.0) -> void:
	_move_picture(picture_name, true, duration)


func _move_picture(picture_name: String, to_bottom: bool, duration: float) -> void:
	var picture: TextureRect = _pictures.get(picture_name)
	if not is_instance_valid(picture):
		return
	var target_y: float = size.y - picture.size.y if to_bottom else 0.0
	var tween = create_tween()
	tween.tween_property(picture, "position:y", target_y, maxf(duration, 0.0)).set_trans(Tween.TRANS_SINE)
	await tween.finished
	return

func _find_picture(picture_name: String) -> String:
	var direct_path: String = PICTURES_DIR + picture_name
	if ResourceLoader.exists(direct_path):
		return direct_path
	for extension: String in ["png", "jpg", "jpeg", "webp"]:
		var path: String = "%s.%s" % [direct_path, extension]
		if ResourceLoader.exists(path):
			return path
	return ""


func _preset_for(position: POSITION) -> Control.LayoutPreset:
	match position:
		POSITION.UP: return Control.PRESET_CENTER_TOP
		POSITION.LEFT: return Control.PRESET_CENTER_LEFT
		POSITION.RIGHT: return Control.PRESET_CENTER_RIGHT
		_: return Control.PRESET_CENTER_BOTTOM
