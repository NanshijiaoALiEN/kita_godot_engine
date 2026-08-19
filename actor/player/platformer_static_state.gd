extends State

@export var player:Player

func Enter() -> void:
	player.set_stamina_input_enabled(false)
	player.velocity.x = 0.0
	
func Physics_Update(_delta:float) -> void:
	player.velocity.y += ProjectSettings.get("physics/2d/default_gravity")

func _on_player_go_move_state() -> void:
	transition.emit(self, "PlatformerMoveState")

func _on_player_go_nav_state(goal: Node2D) -> void:
	transition.emit(self, "PlatformerNavState")
