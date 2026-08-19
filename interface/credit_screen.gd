extends Menu
class_name CreditScreen

#@export_category("製作人員")
#@export_group("負責城市")
#@export var city_name: String = "人員姓名"
#@export var city_url: String = ""
#
#@export_group("負責文本")
#@export var text_name: String = "人員姓名"
#@export var text_url: String = ""
#
#@export_group("負責音效")
#@export var sound_name: String = "人員姓名"
#@export var sound_url: String = ""
#
#@export_group("素材提供")
#@export var assets_name: String = "人員姓名"
#@export var assets_url: String = ""

@onready var city_button: LinkButton = %CityName
@onready var text_button: LinkButton = %TextName
@onready var sound_button: LinkButton = %SoundName
@onready var assets_button: LinkButton = %AssetsName
@onready var back_button: Button = %BackButton

func _ready() -> void:
	#_setup_person(city_button, city_name, city_url)
	#_setup_person(text_button, text_name, text_url)
	#_setup_person(sound_button, sound_name, sound_url)
	#_setup_person(assets_button, assets_name, assets_url)
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
	#city_button.disabled = !enabled or city_url.strip_edges().is_empty()
	#text_button.disabled = !enabled or text_url.strip_edges().is_empty()
	#sound_button.disabled = !enabled or sound_url.strip_edges().is_empty()
	#assets_button.disabled = !enabled or assets_url.strip_edges().is_empty()
	mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE

func _setup_person(button: LinkButton, person_name: String, url: String) -> void:
	button.text = person_name
	button.tooltip_text = url
	button.pressed.connect(_open_social_link.bind(url))

func _open_social_link(url: String) -> void:
	var normalized_url := url.strip_edges()
	if normalized_url.begins_with("https://") or normalized_url.begins_with("http://"):
		OS.shell_open(normalized_url)
