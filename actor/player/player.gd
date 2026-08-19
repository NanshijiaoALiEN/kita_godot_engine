@tool
@icon("res://data/icon/player.svg")
extends CharacterBody2D
class_name Player

enum Direction {
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var state_machine: StateMachine = $StateMachine

@onready var static_state: State = $StateMachine/StaticState
@onready var platformer_static_state: State = $StateMachine/PlatformerStaticState

@export var player_stat:PlayerStat
@export var sprite:ActorSprite
@export var initial_direction:Direction = Direction.UP:
	set(value):
		initial_direction = value
		_apply_initial_direction()
		
@export var player_event_trigger:PlayerEventTrigger
@export_enum("StaticState", "MoveState", "ClimbState") var initial_state:String = "IdleState"
@export var is_platformer:bool = false
@export var balloon:AnimatedSprite2D

var input_vector:Vector2
var stamina_input_enabled:bool = false
var _is_navigating:bool = false
var is_climbing:bool = false

signal go_static_state
signal go_move_state
signal go_idle_state
signal go_nav_state(goal:Node2D)
signal go_nav_finished
signal go_climb_state

func _ready() -> void:
	_apply_initial_direction()
	if !Engine.is_editor_hint():
		if is_platformer:
			state_machine.current_state = platformer_static_state
			motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
			
		else:
			state_machine.current_state = static_state
			motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

func start():
	match initial_state:
		"StaticState":
			go_static()
			
		"IdleState":
			go_idle()
			
		"MoveState":
			go_move()
			
		"ClimbState":
			go_climb()

func get_input() -> Vector2:
	input_vector = Input.get_vector(&"left", &"right", &"up", &"down").normalized()
	return input_vector
	
func go_idle() -> void:
	go_idle_state.emit()

func go_static() -> void:
	go_static_state.emit()
	
func go_move() -> void:
	go_move_state.emit()
	
func go_nav(goal:Node2D) -> void:
	if _is_navigating:
		push_error("Player.go_nav() was called while navigation is already active.")
		return
		
	_is_navigating = true
	go_nav_state.emit(goal)
	await go_nav_finished
	return
	
func go_climb() -> void:
	go_climb_state.emit()

func switch_platformer() -> void:
	pass

func jump() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "position:y", -36, 0.2).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "position:y", 0, 0.2).set_ease(Tween.EASE_IN)
	await tween.finished
	return

func set_direction(direction: Direction = Direction.UP):
	match direction:
		Direction.DOWN:
			sprite.set_idle_animation(Vector2.DOWN)
		Direction.LEFT:
			sprite.set_idle_animation(Vector2.LEFT)
		Direction.RIGHT:
			sprite.set_idle_animation(Vector2.RIGHT)
		_:
			sprite.set_idle_animation(Vector2.UP)


func show_balloon(emotion:StringName):
	if balloon.sprite_frames.has_animation(emotion):
		balloon.show()
		balloon.play(emotion)
		await balloon.animation_finished
		balloon.hide()

func finish_go_nav() -> void:
	if !_is_navigating:
		return
		
	_is_navigating = false
	go_nav_finished.emit()

func set_stamina_input_enabled(enabled:bool) -> void:
	stamina_input_enabled = enabled

func can_run() -> bool:
	return (
		stamina_input_enabled
		and player_stat != null
		and input_vector != Vector2.ZERO
		and Input.is_action_pressed(&"run")
		and player_stat.has_stamina()
	)
	
func _physics_process(delta: float) -> void:
	if !Engine.is_editor_hint():
		get_input()
		_update_stamina(delta)
		move_and_slide()
		
		
	else:
		_apply_initial_direction()

func _update_stamina(delta:float) -> void:
	if !stamina_input_enabled or !player_stat:
		return

	if Input.is_action_pressed(&"run"):
		player_stat.consume_stamina(player_stat.stamina_drain_rate * delta)
	else:
		player_stat.recover_stamina(player_stat.stamina_recovery_rate * delta)
		
func _apply_initial_direction() -> void:
	if !sprite or !sprite.is_node_ready():
		return
		
	sprite.set_idle_animation(_get_initial_direction_vector())

func _get_initial_direction_vector() -> Vector2:
	match initial_direction:
		Direction.DOWN:
			return Vector2.DOWN
		Direction.LEFT:
			return Vector2.LEFT
		Direction.RIGHT:
			return Vector2.RIGHT
		_:
			return Vector2.UP
			
func set_event_trigger_direction():
	if Input.is_action_just_pressed(&"up"):
		player_event_trigger.rotation_degrees = 90
		
	if Input.is_action_just_pressed(&"down"):
		player_event_trigger.rotation_degrees = 270
		
	if Input.is_action_just_pressed(&"left"):
		player_event_trigger.rotation_degrees = 0
		
	if Input.is_action_just_pressed(&"right"):
		player_event_trigger.rotation_degrees = 180
		
		
