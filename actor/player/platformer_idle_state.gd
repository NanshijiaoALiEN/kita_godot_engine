extends State

@export var player:Player

func Physics_Update(_delta:float) -> void:
	player.set_event_trigger_direction()
	player.velocity.x = move_toward(player.velocity.x, 0.0, player.player_stat.friction)
	player.velocity.y += ProjectSettings.get("physics/2d/default_gravity")
	
	if player.input_vector != Vector2.ZERO:
		transition.emit(self, "PlatformerMoveState")

func _on_player_go_static_state() -> void:
	transition.emit(self, "PlatformerStaticState")
