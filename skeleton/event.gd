## Event Skeleton
extends Node

func dialogue_event(dialogue:DialogueResource, title:String = "start") -> void:
	
	var previous_state: Game.GAMESTATE = Game.game_state
	Game.set_game_state(Game.GAMESTATE.DIALOGUE)
	DialogueManager.show_dialogue_balloon(dialogue, title)
	await DialogueManager.dialogue_ended
	Game.set_game_state(previous_state)
	return
