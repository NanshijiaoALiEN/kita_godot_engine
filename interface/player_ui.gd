# Player UI
extends Control
class_name PlayerUI


@onready var health_bar: ProgressBar = %HealthBar
@onready var health_label: Label = %HealthValueLabel
@onready var stamina_bar: ProgressBar = %StaminaBar
@onready var stamina_label: Label = %StaminaValueLabel

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	call_deferred("_update_stat_bars")

func _update_stat_bars() -> void:
	if !is_instance_valid(World.player) or !World.player.player_stat:
		health_bar.value = 0.0
		stamina_bar.value = 0.0
		health_label.text = "- / -"
		stamina_label.text = "- / -"
		return

	var player_stat: PlayerStat = World.player.player_stat
	health_bar.max_value = maxf(float(player_stat.max_health), 1.0)
	health_bar.value = clampf(float(player_stat.health), 0.0, health_bar.max_value)
	health_label.text = "%d / %d" % [player_stat.health, player_stat.max_health]

	stamina_bar.max_value = maxf(float(player_stat.max_stamina), 1.0)
	stamina_bar.value = clampf(float(player_stat.stamina), 0.0, stamina_bar.max_value)
	stamina_label.text = "%d / %d" % [roundi(player_stat.stamina), roundi(player_stat.max_stamina)]

func on_stamina_change(_value:float) -> void:
	_update_stat_bars()

func on_health_change(_value:int) -> void:
	_update_stat_bars()
