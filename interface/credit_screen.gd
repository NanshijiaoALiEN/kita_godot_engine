extends Menu
class_name CreditScreen

@onready var back_button: Button = %BackButton

func _ready() -> void:
	back_button.pressed.connect(close)
	set_enabled(false)
	reset_closed()

func open() -> void:
	Sound.play_sound(Sound.EVENT_SOUND.SELECT)
	if await fade_in():
		set_enabled(true)

func close() -> void:
	Sound.play_sound(Sound.EVENT_SOUND.BACK)
	set_enabled(false)
	if await fade_out():
		_on_menu_close.emit()

func set_enabled(enabled: bool) -> void:
	back_button.disabled = !enabled
	mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE
