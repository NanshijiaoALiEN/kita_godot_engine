extends State

@export var player:Player
@export var nav_agent:NavigationAgent2D

var nav_goal:Node2D
var last_direction := Vector2.DOWN

func Enter() -> void:
	if player:
		player.set_stamina_input_enabled(false)
	last_direction = Vector2.DOWN

func Exit() -> void:
	nav_goal = null

func Physics_Update(_delta:float) -> void:
	var agent := _get_nav_agent()
	if !player or !agent or !is_instance_valid(nav_goal) or agent.is_navigation_finished():
		_finish_navigation()
		return

	var direction := player.global_position.direction_to(agent.get_next_path_position())
	if direction == Vector2.ZERO:
		_finish_navigation()
		return

	last_direction = direction
	player.sprite.set_walk_animation(direction)
	player.velocity = player.velocity.move_toward(
		direction * player.player_stat.max_speed,
		player.player_stat.acceleration
	)

func _on_player_go_nav_state(goal: Node2D) -> void:
	nav_goal = goal
	_set_nav_target()

func _get_nav_agent() -> NavigationAgent2D:
	if nav_agent:
		return nav_agent
	if player:
		return player.nav_agent
	return null

func _set_nav_target() -> void:
	var agent := _get_nav_agent()
	if agent and is_instance_valid(nav_goal):
		agent.target_position = nav_goal.global_position

func _finish_navigation() -> void:
	if player:
		player.velocity = Vector2.ZERO
		if player.sprite:
			player.sprite.set_idle_animation(last_direction)

	nav_goal = null
	transition.emit(self, "StaticState")

	if player:
		player.finish_go_nav()
