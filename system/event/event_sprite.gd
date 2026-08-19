@icon("res://data/icon/event_sprite.svg")
extends EventComponent
class_name EventSprite

@onready var sprite:Sprite2D = $Sprite2D
@onready var animation_player:AnimationPlayer = $AnimationPlayer

var player_in_trigger_count:int = 0

func component_setup() -> void:
	if not animation_player.animation_finished.is_connected(_on_animation_finished):
		animation_player.animation_finished.connect(_on_animation_finished)

	if not event_tree:
		_play_idle()
		return

	if not event_tree.on_tree_start.is_connected(_on_event_tree_start):
		event_tree.on_tree_start.connect(_on_event_tree_start)

	if not event_tree.on_disable_changed.is_connected(_on_event_tree_disable_changed):
		event_tree.on_disable_changed.connect(_on_event_tree_disable_changed)

	_connect_event_triggers()
	_apply_disable(event_tree.disable)

func _on_event_tree_start() -> void:
	if event_tree and event_tree.disable:
		return

	visible = true
	animation_player.play(&"trigger")

func _on_player_entered_trigger() -> void:
	if event_tree and event_tree.disable:
		return

	player_in_trigger_count += 1
	if animation_player.current_animation == "trigger":
		return

	visible = true
	animation_player.play(&"react")

func _on_player_exited_trigger() -> void:
	player_in_trigger_count = maxi(player_in_trigger_count - 1, 0)
	if event_tree and event_tree.disable:
		return
	if player_in_trigger_count > 0:
		return
	if animation_player.current_animation == "trigger":
		return

	_play_idle()

func _on_event_tree_disable_changed(disabled: bool) -> void:
	_apply_disable(disabled)

func _on_animation_finished(animation_name: StringName) -> void:
	if not visible:
		return

	if animation_name == &"trigger" or animation_name == &"react":
		_play_ready_or_idle()

func _apply_disable(disabled: bool) -> void:
	visible = not disabled
	if disabled:
		player_in_trigger_count = 0
		animation_player.stop()
	else:
		_play_idle()

func _connect_event_triggers() -> void:
	for child in event_tree.get_children():
		if child is EventTrigger:
			if not child._on_player_entered.is_connected(_on_player_entered_trigger):
				child._on_player_entered.connect(_on_player_entered_trigger)
			if not child._on_player_exited.is_connected(_on_player_exited_trigger):
				child._on_player_exited.connect(_on_player_exited_trigger)

func _play_ready_or_idle() -> void:
	if player_in_trigger_count > 0:
		_play_ready()
	else:
		_play_idle()

func _play_ready() -> void:
	visible = true
	animation_player.play(&"ready")

func _play_idle() -> void:
	visible = true
	animation_player.play(&"idle")
