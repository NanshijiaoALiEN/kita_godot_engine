## Global music and one-shot sound playback service.
##
## Root injects the audio players and assigns their buses. EVENT_SOUND values map
## by index to [member event_sounds], so keep the enum and array in the same order.
extends Node

var music_player:AudioStreamPlayer
var sound_player:AudioStreamPlayer


enum EVENT_SOUND {
	TEST_SOUND,
	CONFIRM,
	SELECT,
	BACK,
	BOOM_1
}

## Audio streams indexed by EVENT_SOUND.
var event_sounds:Array[AudioStream] = [
	preload("res://data/sound/test_sound.tres"),
	preload("res://data/sound/test_sound.tres"),
	preload("res://data/sound/test_sound.tres"),
	preload("res://data/sound/test_sound.tres"),
	preload("res://data/sound/test_sound.tres"),
]

## Replace the current music, optionally fading the old and new tracks.
func play_music(stream:AudioStream, fade_in_time:float = 1.0) -> void:
	if music_player.stream == stream and music_player.playing:
		return
	
	await stop_music(fade_in_time)
	music_player.stream = stream
	music_player.volume_db = -80.0 if fade_in_time > 0.0 else 0.0
	music_player.play()

	if fade_in_time > 0.0:
		music_player.create_tween().tween_property(
			music_player,
			"volume_db",
			0.0,
			fade_in_time
		)


func stop_music(fade_out_time:float = 1.0) -> void:
	if not music_player.playing:
		return

	if fade_out_time <= 0.0:
		music_player.stop()
		music_player.volume_db = 0.0
		return

	var tween := music_player.create_tween()
	tween.tween_property(music_player, "volume_db", -80.0, fade_out_time)
	tween.tween_callback(music_player.stop)
	tween.tween_callback(func() -> void: music_player.volume_db = 0.0)
	await tween.finished
	return


func change_volume(linear_volume:float, fade_time:float) -> void:
	var target_volume_linear:float = maxf(linear_volume, 0.0)
	if fade_time <= 0.0:
		music_player.volume_linear = target_volume_linear
		return

	music_player.create_tween().tween_property(
		music_player,
		"volume_linear",
		target_volume_linear,
		fade_time
	)
	
## Play one mapped event sound and wait for the shared player to finish.
func play_sound(event_sound:EVENT_SOUND = EVENT_SOUND.TEST_SOUND) -> void:
	var sound_index := int(event_sound)
	if sound_index < 0 or sound_index >= event_sounds.size():
		push_warning("找不到 EVENT_SOUND 對應的音效：%s" % sound_index)
		return

	var stream := event_sounds[sound_index]
	if stream == null:
		push_warning("EVENT_SOUND.%s not set yet" % EVENT_SOUND.find_key(sound_index))
		return

	sound_player.stream = stream
	sound_player.play()
	
	await sound_player.finished
	return

func play():
	pass


func load_sound_resource(path:String) -> AudioStream:
	if FileAccess.file_exists(path):
		return ResourceLoader.load(path)
		
	else:
		assert(false, "File not existed")
		return null
