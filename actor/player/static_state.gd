extends State

@export var player:Player


func Enter() -> void:
	player.set_stamina_input_enabled(false)
	player.velocity = Vector2.ZERO

func _on_player_go_move_state() -> void:
	transition.emit(self, "IdleState")

func _on_player_go_nav_state(_goal: Node2D) -> void:
	transition.emit(self, "NavState")

func _on_player_go_climb_state() -> void:
	transition.emit(self, "ClimbState")
