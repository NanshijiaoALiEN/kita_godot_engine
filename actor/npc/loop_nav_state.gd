extends State

@export var npc:NPC
@export var nav_agent:NavigationAgent2D

var nav_point_group:Array[LoopNavPoint]
var loop_nav_group:LoopNavGroup
var current_nav_index:int
var is_waiting:bool
var wait_until_msec:int
var last_direction:Vector2 = Vector2.DOWN

func Enter() -> void:
	current_nav_index = 0
	is_waiting = false
	wait_until_msec = 0
	last_direction = Vector2.DOWN
	get_nav_point_group()
	_set_current_nav_target()

func Exit() -> void:
	is_waiting = false
	nav_point_group.clear()
	
	if npc:
		npc.velocity = Vector2.ZERO

func Physics_Update(_delta:float) -> void:
	if !npc or !npc.character_data or !nav_agent or nav_point_group.is_empty():
		_finish_loop_navigation()
		return
		
	if is_waiting:
		npc.velocity = Vector2.ZERO
		
		if Time.get_ticks_msec() < wait_until_msec:
			return
			
		is_waiting = false
		_go_next_nav_point()
		return
		
	if nav_agent.is_navigation_finished():
		_start_waiting()
		return
		
	var next_path_position := nav_agent.get_next_path_position()
	var direction := npc.global_position.direction_to(next_path_position)
	if direction == Vector2.ZERO:
		_start_waiting()
		return
		
	last_direction = direction
	if npc.sprite and npc.sprite.is_node_ready():
		npc.sprite.set_walk_animation(direction)
		
	npc.velocity = npc.velocity.move_toward(
		direction * npc.character_data.max_speed,
		npc.character_data.acceleration
	)

func get_nav_point_group() -> void:
	loop_nav_group = null
	nav_point_group.clear()
	
	if !npc:
		return
		
	if npc.get_node_or_null(^"LoopNavGroup") is LoopNavGroup:
		loop_nav_group = npc.get_node_or_null(^"LoopNavGroup")
	
	if loop_nav_group:
		nav_point_group = loop_nav_group.get_nav_point_group()


func _set_current_nav_target() -> void:
	if !nav_agent or nav_point_group.is_empty():
		return
		
	nav_agent.target_position = nav_point_group[current_nav_index].global_position

func _go_next_nav_point() -> void:
	current_nav_index += 1
	
	if current_nav_index >= nav_point_group.size():
		current_nav_index = 0
		
	_set_current_nav_target()

func _start_waiting() -> void:
	npc.velocity = Vector2.ZERO
	
	if npc.sprite and npc.sprite.is_node_ready():
		npc.sprite.set_idle_animation(last_direction)
		
	var current_nav_point := nav_point_group[current_nav_index]
	if current_nav_point.wait_time <= 0.0:
		_go_next_nav_point()
		return
		
	is_waiting = true
	wait_until_msec = Time.get_ticks_msec() + int(current_nav_point.wait_time * 1000.0)

func _finish_loop_navigation() -> void:
	if npc:
		npc.velocity = Vector2.ZERO
		
		if npc.sprite and npc.sprite.is_node_ready():
			npc.sprite.set_idle_animation(last_direction)
			
	is_waiting = false
	nav_point_group.clear()
	transition.emit(self, "IdleState")

func _on_npc_go_idle_state() -> void:
	is_waiting = false
	wait_until_msec = 0
	nav_point_group.clear()

	if npc:
		npc.velocity = Vector2.ZERO

		if nav_agent:
			nav_agent.target_position = npc.global_position

		if npc.sprite and npc.sprite.is_node_ready():
			npc.sprite.set_idle_animation(last_direction)

	transition.emit(self, "IdleState")
