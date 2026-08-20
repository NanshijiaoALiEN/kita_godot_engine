## Registry of scene-owned UI services used by runtime systems.
##
## Root assigns these references during startup. Autoloads and gameplay scripts
## should use this registry instead of searching the scene tree for global UI.
extends Node

var title_screen:TitleScreen
var pause_screen:PauseScreen
var transition:TransitionScreen
var player:PicturePlayer
