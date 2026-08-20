extends Resource
## Shared movement and stamina tuning data for Player states.
##
## Runtime stamina is clamped to [member max_stamina] and emits change/depletion
## signals so UI and state logic do not need to poll the value.
class_name PlayerStat

signal on_health_change(value:int)
signal on_stamina_change(value:float)
signal on_stamina_depleted

@export var max_speed:float = 150.0
@export var run_speed:float = 300.0
@export var acceleration:float = 40.0
@export var friction:float = 40.0
@export var jump_speed:float = 300.0
@export var climb_speed:float = 100.0

@export var max_health:int = 1000
var health:int = 1000:
	set(value):
		health = value

@export var max_stamina:float = 10000.0
@export var stamina_drain_rate:float = 1000.0
@export var stamina_recovery_rate:float = 2000.0
var stamina:float = 10000.0:
	set(value):
		var previous_stamina := stamina
		var next_stamina := clampf(value, 0.0, max_stamina)
		if is_equal_approx(stamina, next_stamina):
			return

		stamina = next_stamina
		on_stamina_change.emit(stamina)

		if previous_stamina > 0.0 and is_zero_approx(stamina):
			on_stamina_depleted.emit()

func consume_stamina(amount:float) -> void:
	if amount <= 0.0:
		return

	stamina -= amount

func recover_stamina(amount:float) -> void:
	if amount <= 0.0:
		return

	stamina += amount

func has_stamina() -> bool:
	return stamina > 0.0
