extends Control
class_name Menu

signal _on_menu_open
signal _on_menu_close
signal _fade_completed(fade_id: int)

const DEFAULT_FADE_DURATION: float = 0.2

var _fade_tween: Tween
var _fade_id: int = 0

func open() -> void:
	pass
	
func close() -> void:
	pass

func fade_in(duration: float = DEFAULT_FADE_DURATION) -> bool:
	if !visible:
		modulate.a = 0.0

	show()
	return await _fade_to(1.0, duration)

func fade_out(duration: float = DEFAULT_FADE_DURATION) -> bool:
	if !visible:
		modulate.a = 0.0
		hide()
		return true

	if await _fade_to(0.0, duration):
		hide()
		return true

	return false

func reset_closed() -> void:
	_begin_fade()
	modulate.a = 0.0
	hide()

func reset_open() -> void:
	_begin_fade()
	modulate.a = 1.0
	show()

func _fade_to(alpha: float, duration: float) -> bool:
	var current_fade_id := _begin_fade()

	if duration <= 0.0:
		modulate.a = alpha
		return true

	_fade_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_fade_tween.tween_property(self, "modulate:a", alpha, duration)
	_fade_tween.finished.connect(_complete_fade.bind(current_fade_id), CONNECT_ONE_SHOT)

	var completed_fade_id: int = await _fade_completed
	if completed_fade_id != current_fade_id or current_fade_id != _fade_id:
		return false

	_fade_tween = null
	return true

func _complete_fade(completed_fade_id: int) -> void:
	_fade_completed.emit(completed_fade_id)

func _begin_fade() -> int:
	var previous_fade_id := _fade_id
	_fade_id += 1

	if _fade_tween:
		_fade_tween.kill()
		_fade_tween = null
		_fade_completed.emit(previous_fade_id)

	return _fade_id
