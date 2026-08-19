extends State

@export var npc:NPC
@export var nav_agent:NavigationAgent2D

var nav_goal:Node2D
var last_direction:Vector2 = Vector2.DOWN

func Enter() -> void:
	last_direction = Vector2.DOWN

func Exit() -> void:
	nav_goal = null

func Physics_Update(_delta:float) -> void:
	if !npc or !npc.character_data or !nav_agent or !is_instance_valid(nav_goal):
		_finish_navigation()
		return
		
	if nav_agent.is_navigation_finished():
		_finish_navigation()
		return
		
	var next_path_position := nav_agent.get_next_path_position()
	var direction := npc.global_position.direction_to(next_path_position)
	if direction == Vector2.ZERO:
		_finish_navigation()
		return
		
	last_direction = direction
	if npc.sprite and npc.sprite.is_node_ready():
		npc.sprite.set_walk_animation(direction)
		
	npc.velocity = npc.velocity.move_toward(
		direction * npc.character_data.max_speed,
		npc.character_data.acceleration
	)

func _on_npc_go_nav_state(goal: Node2D) -> void:
	nav_goal = goal
	
	if nav_agent and is_instance_valid(nav_goal):
		nav_agent.target_position = nav_goal.global_position

func _finish_navigation() -> void:
	if npc:
		npc.velocity = Vector2.ZERO
		
		if npc.sprite and npc.sprite.is_node_ready():
			npc.sprite.set_idle_animation(last_direction)
		
	nav_goal = null
	transition.emit(self, "IdleState")
