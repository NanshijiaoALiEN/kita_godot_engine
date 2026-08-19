extends State

@export var player:Player


func Physics_Update(_delta:float) -> void:
	if player.input_vector != Vector2.ZERO:
		player.sprite.set_walk_animation(Vector2(0, -player.input_vector.length()))
		
	else:
		player.sprite.set_idle_animation(Vector2(0, -1))
		
	player.velocity = player.velocity.move_toward(player.input_vector * \
	player.player_stat.climb_speed, player.player_stat.acceleration)

func _on_player_go_move_state() -> void:
	transition.emit(self, "MoveState")

func _on_player_go_static_state() -> void:
	transition.emit(self, "StaticState")
