extends State

@export var player:Player
var last_vector:Vector2

func Enter() -> void:
	player.set_stamina_input_enabled(true)

func Physics_Update(_delta:float) -> void:
	player.set_event_trigger_direction()
	
	var speed:float
	
	if player.can_run():
		speed = player.player_stat.run_speed
		player.sprite.set_run_speed(3.0)
		
	else:
		speed = player.player_stat.max_speed
		player.sprite.set_run_speed(2.0)
	
	if player.is_climbing:
		player.sprite.set_walk_animation(Vector2(0, -player.input_vector.normalized().length()))
		
	else:
		player.sprite.set_walk_animation(player.input_vector)
		
		
	player.velocity = player.velocity.move_toward(speed * player.input_vector, player.player_stat.acceleration)
	
	if player.input_vector == Vector2.ZERO:
		if player.is_climbing:
			player.sprite.set_idle_animation(Vector2(0, -1))
			
		else:
			player.sprite.set_idle_animation(last_vector)
			
		transition.emit(self, "IdleState")

	last_vector = player.input_vector
	

func _on_player_go_static_state() -> void:
	transition.emit(self, "StaticState")

func _on_player_go_climb_state() -> void:
	transition.emit(self, "ClimbState")
