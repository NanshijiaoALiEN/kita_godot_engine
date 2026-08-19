# Pause Screen
extends Menu
class_name PauseScreen

signal resume_requested
signal title_requested

@onready var main_menu: Control = %MainMenu
@onready var settings_menu: SettingsMenu = %SettingsMenu
@onready var save_slot_menu: SaveSlotMenu = %SaveSlotMenu
@onready var resume_button: Button = %ResumeButton
@onready var save_button: Button = %SaveButton
@onready var load_button: Button = %LoadButton
@onready var settings_button: Button = %SettingsButton
@onready var title_button: Button = %TitleButton

func _ready() -> void:
	settings_menu.back_requested.connect(_on_settings_menu_back_requested)
	save_slot_menu._on_menu_close.connect(show_main_menu)
	set_enabled(false)
	reset_closed()

func open() -> void:
	Sound.play_sound(Sound.EVENT_SOUND.CONFIRM)
	main_menu.show()
	settings_menu.set_enabled(false)
	settings_menu.reset_closed()
	save_slot_menu.reset_closed()
	if await fade_in():
		set_enabled(true)
		_on_menu_open.emit()
		
	resume_button.grab_focus()

func close() -> void:
	set_enabled(false)
	if await fade_out():
		main_menu.show()
		settings_menu.set_enabled(false)
		settings_menu.reset_closed()
		save_slot_menu.reset_closed()
		_on_menu_close.emit()

func set_enabled(enabled: bool) -> void:
	resume_button.disabled = !enabled
	save_button.disabled = !enabled
	load_button.disabled = !enabled
	settings_button.disabled = !enabled
	title_button.disabled = !enabled
	mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE

func show_main_menu() -> void:
	main_menu.show()
	settings_menu.set_enabled(false)
	settings_menu.reset_closed()
	save_slot_menu.reset_closed()

func show_settings_menu() -> void:
	main_menu.hide()
	settings_menu.open()

func show_save_slot_menu(mode:SaveSlotMenu.Mode) -> void:
	main_menu.hide()
	save_slot_menu.open(mode)

func _on_resume_button_pressed() -> void:
	resume_requested.emit()

func _on_settings_button_pressed() -> void:
	show_settings_menu()

func _on_save_button_pressed() -> void:
	show_save_slot_menu(SaveSlotMenu.Mode.SAVE)

func _on_load_button_pressed() -> void:
	show_save_slot_menu(SaveSlotMenu.Mode.LOAD)

func _on_title_button_pressed() -> void:
	title_requested.emit()

func _on_settings_menu_back_requested() -> void:
	show_main_menu()
	resume_button.grab_focus()
