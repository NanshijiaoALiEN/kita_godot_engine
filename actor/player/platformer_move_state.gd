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
	
	player.sprite.set_walk_animation(player.input_vector)
	player.velocity.x = move_toward(player.velocity.x, speed * player.input_vector.x, player.player_stat.acceleration)
	player.velocity.y += ProjectSettings.get("physics/2d/default_gravity")
	
	if player.input_vector == Vector2.ZERO:
		player.sprite.set_idle_animation(last_vector)
		transition.emit(self, "PlatformerIdleState")

	last_vector = player.input_vector

func _on_player_go_static_state() -> void:
	transition.emit(self, "PlatformerStaticState")
	
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"jump") and player.is_on_floor():
		player.velocity.y = -500
