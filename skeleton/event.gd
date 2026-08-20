## Shared facade for game-wide event helpers that do not belong to one scene.
##
## Dialogue playback temporarily changes Game to DIALOGUE and restores the
## previous state after Dialogue Manager reports completion.
extends Node

## Show a Dialogue Manager resource and wait until the conversation ends.
func dialogue_event(dialogue:DialogueResource, title:String = "start") -> void:
	
	var previous_state: Game.GAMESTATE = Game.game_state
	Game.set_game_state(Game.GAMESTATE.DIALOGUE)
	DialogueManager.show_dialogue_balloon(dialogue, title)
	await DialogueManager.dialogue_ended
	Game.set_game_state(previous_state)
	return
