# Checkpoint Menu
extends Menu
class_name CheckpointMenu

signal preview_requested
signal travel_requested
signal close_requested

@onready var panel: Panel = %Panel
@onready var preview_button: Button = %PreviewButton
@onready var travel_button: Button = %TravelButton
@onready var close_button: Button = %CloseButton

func open() -> void:
	show()
	set_enabled(true)

func close() -> void:
	hide()
	set_enabled(false)

func set_enabled(enabled: bool) -> void:
	preview_button.disabled = !enabled
	travel_button.disabled = !enabled
	close_button.disabled = !enabled
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE

func _on_preview_button_pressed() -> void:
	preview_requested.emit()

func _on_travel_button_pressed() -> void:
	travel_requested.emit()

func _on_close_button_pressed() -> void:
	close_requested.emit()

func _on_girl_data_button_pressed() -> void:
	pass # Replace with function body.
