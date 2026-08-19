@tool
extends Sprite2D
class_name ActorSprite

@onready var animation_tree: AnimationTree = %AnimationTree

func set_idle_animation(vector:Vector2):
	animation_tree.set("parameters/BlendTree/is_idle/blend_amount", 1.0)
	animation_tree.set("parameters/BlendTree/idle/blend_position", vector)

func set_walk_animation(vector:Vector2 = Vector2.ZERO):
	animation_tree.set("parameters/BlendTree/is_idle/blend_amount", 0.0)
	animation_tree.set("parameters/BlendTree/walk/blend_position", vector)

func set_run_speed(value:float = 2.0):
	animation_tree.set("parameters/BlendTree/time_scale/scale", value)
