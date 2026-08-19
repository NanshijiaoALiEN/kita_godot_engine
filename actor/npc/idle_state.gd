extends State

@export var npc:NPC

func Enter() -> void:
	npc.velocity = Vector2.ZERO

func _on_npc_go_nav_state(goal: Node2D) -> void:
	transition.emit(self, "NavState")

func _on_npc_go_loop_nav_state() -> void:
	transition.emit(self, "LoopNavState")
