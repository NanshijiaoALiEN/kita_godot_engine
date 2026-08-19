@tool
@icon("res://data/icon/npc.svg")
extends CharacterBody2D
class_name NPC

enum Direction {
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

@export var character_data:CharacterData
@export var sprite:ActorSprite
@export var initial_direction:Direction = Direction.UP:
	set(value):
		initial_direction = value
		_apply_initial_direction()
@onready var balloon: AnimatedSprite2D = $Balloon

signal go_nav_state(goal:Node2D)
signal go_loop_nav_state()
signal go_idle_state()

func _ready() -> void:
	_apply_initial_direction()

func go_nav(goal:Node2D) -> void:
	go_nav_state.emit(goal)
	
func go_loop_nav() -> void:
	go_loop_nav_state.emit()
	
func go_idle() -> void:
	go_idle_state.emit()

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

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		_apply_initial_direction()

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
