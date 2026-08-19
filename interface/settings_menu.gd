# Settings Menu
extends Menu
class_name SettingsMenu

signal back_requested

@onready var master_slider: HSlider = %MasterSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var sound_slider: HSlider = %SoundSlider
@onready var back_button: Button = %BackButton

func _ready() -> void:
	master_slider.value_changed.connect(_on_master_slider_value_changed)
	music_slider.value_changed.connect(_on_music_slider_value_changed)
	sound_slider.value_changed.connect(_on_sound_slider_value_changed)
	back_button.pressed.connect(_on_back_button_pressed)
	set_enabled(false)
	reset_closed()

func open() -> void:
	Sound.play_sound(Sound.EVENT_SOUND.SELECT)
	load_from_config_data()
	if await fade_in():
		set_enabled(true)

func close() -> void:
	set_enabled(false)
	if await fade_out():
		_on_menu_close.emit()

func set_enabled(enabled: bool) -> void:
	master_slider.editable = enabled
	music_slider.editable = enabled
	sound_slider.editable = enabled
	back_button.disabled = !enabled
	mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE

func load_from_config_data() -> void:
	if !Game.config_data:
		return

	master_slider.value = Game.config_data.master_volume
	music_slider.value = Game.config_data.music_volume
	sound_slider.value = Game.config_data.sound_volume
	Game.apply_config()

func _on_master_slider_value_changed(value: float) -> void:
	Game.config_data.master_volume = value
	Game.apply_config()

func _on_music_slider_value_changed(value: float) -> void:
	Game.config_data.music_volume = value
	Game.apply_config()

func _on_sound_slider_value_changed(value: float) -> void:
	Game.config_data.sound_volume = value
	Game.apply_config()

func _on_back_button_pressed() -> void:
	Sound.play_sound(Sound.EVENT_SOUND.BACK)
	Game.save_config()

	await close()
	back_requested.emit()
