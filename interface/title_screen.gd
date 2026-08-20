# Title Screen
extends Menu
class_name TitleScreen


@onready var new_game_button: Button = %NewGameButton
@onready var continue_button: Button = %ContinueButton
@onready var settings_button: Button = %SettingsButton
@onready var credit_button: Button = %CreditButton
@onready var main_menu: Control = %MainMenu
@onready var settings_menu: SettingsMenu = %SettingsMenu
@onready var credit_screen: CreditScreen = %CreditScreen
@onready var save_slot_menu: SaveSlotMenu = %SaveSlotMenu
@onready var title_screen_2: TextureRect = $TitleScreen2

var continue_available: bool = false
var is_enabled: bool = false

func _ready() -> void:
	_update_continue_button()
	settings_menu._on_menu_close.connect(open)
	credit_screen._on_menu_close.connect(open)
	Game.on_game_loaded.connect(_on_game_loaded)

func open() -> void:
	_update_continue_button()
	
	show()
	_on_menu_open.emit()

func close() -> void:
	hide()
	_on_menu_close.emit()

func show_settings_menu() -> void:
	#main_menu.hide()
	settings_menu.open()

func show_credit_screen() -> void:
	credit_screen.open()

func _on_new_game_button_pressed() -> void:
	Sound.play_sound(Sound.EVENT_SOUND.SELECT)
	Game.new_game()
	Sound.stop_music(1.0)
	await World.switch_level(World.DEFAULT_LEVEL)
	close()

func _on_continue_button_pressed() -> void:
	Sound.play_sound(Sound.EVENT_SOUND.SELECT)
	if !continue_available:
		return
	save_slot_menu.open(SaveSlotMenu.Mode.LOAD)

func _update_continue_button() -> void:
	continue_available = !Game.get_save_slots().is_empty()
	continue_button.visible = continue_available
	new_game_button.grab_focus()
	#new_game_button.visible = !continue_available

func _on_game_loaded() -> void:
	if visible:
		close()

func _on_settings_button_pressed() -> void:
	show_settings_menu()

func _on_credit_button_pressed() -> void:
	show_credit_screen()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
