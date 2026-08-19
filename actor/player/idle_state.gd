extends State

@export var player:Player

func Physics_Update(_delta:float) -> void:
	player.set_event_trigger_direction()
	player.velocity = player.velocity.move_toward(Vector2.ZERO, player.player_stat.friction)
	
	if player.input_vector != Vector2.ZERO:
		transition.emit(self, "MoveState")

func _on_player_go_static_state() -> void:
	transition.emit(self, "StaticState")
