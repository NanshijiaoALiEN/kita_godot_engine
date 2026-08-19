extends State

@export var npc:NPC
var event_tree:EventTree

func _ready() -> void:
	if !npc:
		return

	var tree := npc.get_node_or_null(^"EventTree")
	if tree is EventTree:
		event_tree = tree as EventTree
		event_tree.on_tree_start.connect(_on_event_tree_start)

func _on_event_tree_start() -> void:
	if !is_instance_valid(npc) or !is_instance_valid(World.player):
		return
	if !is_instance_valid(npc.sprite):
		return

	var direction := npc.global_position.direction_to(World.player.global_position)
	if direction == Vector2.ZERO:
		return

	npc.sprite.set_idle_animation(direction)
