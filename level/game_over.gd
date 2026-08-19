extends BaseLevel

@onready var game_over_label: Label = $CanvasLayer/GameOverLabel

func _ready() -> void:
	super()
	
	var tween = create_tween()
	tween.tween_property(game_over_label, "modulate:a", 1.0, 2.0)
	tween.tween_property(game_over_label, "modulate:a", 0.0, 2.0)
	await tween.finished
	
	World.return_to_title()
	
	
