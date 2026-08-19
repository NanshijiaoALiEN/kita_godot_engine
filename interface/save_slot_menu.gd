extends Menu
class_name SaveSlotMenu

enum Mode { SAVE, LOAD }

const SLOT_BUTTON_SCENE:PackedScene = preload("res://interface/save_slot_button.tscn")

@onready var title_label:Label = %TitleLabel
@onready var slot_list:VBoxContainer = %SlotList
@onready var confirmation:Control = %Confirmation
@onready var confirmation_label:Label = %ConfirmationLabel

var mode:Mode = Mode.SAVE
var pending_slot:int = 0

func _ready() -> void:
	reset_closed()

func open(new_mode:Mode = Mode.SAVE) -> void:
	Sound.play_sound(Sound.EVENT_SOUND.SELECT)
	mode = new_mode
	title_label.text = "セーブ" if mode == Mode.SAVE else "ロード"
	confirmation.hide()
	_refresh_slots()
	reset_open()
	_on_menu_open.emit()

func close() -> void:
	Sound.play_sound(Sound.EVENT_SOUND.BACK)
	reset_closed()
	_on_menu_close.emit()

func _refresh_slots() -> void:
	for child in slot_list.get_children():
		child.queue_free()

	var slots:Array[int] = Game.get_save_slots()
	if mode == Mode.SAVE:
		for slot in range(1, Game.MAX_SAVE_SLOTS + 1):
			if Game.has_save(slot):
				_add_slot_button(slot, Game.get_save_data(slot), true)
	else:
		for slot in slots:
			_add_slot_button(slot, Game.get_save_data(slot), true)

	var next_slot:int = Game.get_next_save_slot()
	if mode == Mode.SAVE and next_slot > 0:
		_add_slot_button(next_slot, null, false)
	elif mode == Mode.LOAD and slots.is_empty():
		var empty_label := Label.new()
		empty_label.text = "セーブデータがありません"
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot_list.add_child(empty_label)

func _add_slot_button(slot:int, data:SaveData, exists:bool) -> void:
	var button:Button = SLOT_BUTTON_SCENE.instantiate()
	button.text = "スロット %d  --  %s" % [slot, _format_time(data.total_game_time)] if data else "スロット %d  --  %s" % [slot, "利用不可" if exists else "新規セーブ"]
	button.pressed.connect(_on_slot_pressed.bind(slot, exists))
	slot_list.add_child(button)

func _on_slot_pressed(slot:int, exists:bool) -> void:
	if mode == Mode.LOAD:
		if await Game.load_game(slot):
			close()
	elif exists:
		pending_slot = slot
		confirmation_label.text = "スロット %d に上書きしますか？" % slot
		confirmation.show()
	else:
		_save(slot)

func _save(slot:int) -> void:
	if Game.save_game(slot):
		close()

func _on_confirm_pressed() -> void:
	confirmation.hide()
	_save(pending_slot)

func _on_cancel_pressed() -> void:
	confirmation.hide()

func _format_time(seconds:float) -> String:
	var total_seconds:int = int(seconds)
	return "%02d:%02d:%02d" % [total_seconds / 3600, total_seconds / 60 % 60, total_seconds % 60]
