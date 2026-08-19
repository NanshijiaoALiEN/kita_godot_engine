extends Control
class_name TransitionScreen

@onready var color_rect: ColorRect = $ColorRect
@onready var flashlight: ColorRect = $Flashlight
var fade_tween: Tween

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func set_alpha(alpha: float) -> void:
	color_rect.modulate.a = alpha
	
func show_flashlight(duration:float = 1.0) -> void:
	flashlight.show()
	await _fade_to(flashlight, 1.0, duration)

func hide_flashlight(duration: float = 1.0) -> void:
	await _fade_to(flashlight, 0.0, duration)
	flashlight.hide()

func fade_in(duration: float = 1.0) -> void:
	color_rect.show()
	await _fade_to(color_rect, 1.0, duration)

func fade_out(duration: float = 1.0) -> void:
	await _fade_to(color_rect, 0.0, duration)
	color_rect.hide()

func _fade_to(target:ColorRect, alpha: float, duration: float) -> void:
	if fade_tween:
		fade_tween.kill()

	if duration <= 0.0:
		set_alpha(alpha)
		return

	fade_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	fade_tween.tween_property(target, "modulate:a", alpha, duration)
	await fade_tween.finished
	fade_tween = null
