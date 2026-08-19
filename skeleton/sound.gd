## Sound Skeleton
extends Node

var music_player:AudioStreamPlayer
var sound_player:AudioStreamPlayer


enum EVENT_SOUND {
	DEFAULT,
	BOOM_1,
	BOOM_2,
	DISTANT_BOOM_1,
	DISTANT_BOOM_2,
	DISTANT_BOOM_3,
	RUMBLE,
	FALL,
	GET,
	BODY_HIT,
	SUCCESS,
	FAILED,
	SELECT,
	BACK,
	SQUISH,
	TELEPORT,
	CUM,
	CLOTH,
	CUM_DEEP,
	CONFIRM,
	
	
}

# Array 的索引依序對應 EVENT_SOUND：DEFAULT、CORRECT、FAIL。
# 可直接在 Inspector 中指定各個常用音效。
var event_sounds:Array[AudioStream] = [
	preload("res://data/sound/type_sound.ogg"),
	preload("res://data/sound/boom_step1.mp3"),
	preload("res://data/sound/boom_step2.wav"),
	preload("res://data/sound/Distant Booming Thud 1.wav"),
	preload("res://data/sound/Distant Booming Thud 2.wav"),
	preload("res://data/sound/Distant Booming Thud 3.wav"),
	preload("res://data/sound/rumble.mp3"),
	preload("res://data/sound/Fall.mp3"),
	preload("res://data/sound/computer_OS_welcome_01.ogg"),
	preload("res://data/sound/Bodyfall on Dirt 3.mp3"),
	preload("res://data/sound/Good One - Organ.ogg"),
	preload("res://data/sound/phaserDown3.ogg"),
	preload("res://data/sound/threeTone2.ogg"),
	preload("res://data/sound/twoTone2.ogg"),
	preload("res://data/sound/squishy_thing_08.ogg"),
	preload("res://data/sound/teleport_sound.mp3"),
	preload("res://data/sound/squishy_thing_08.ogg"),
	preload("res://data/sound/Clothes 2.wav"),
	preload("res://data/sound/cum_smash1.wav"),
	preload("res://data/sound/computer_instant_message_alert_02.ogg")]

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
	
func play_sound(event_sound:EVENT_SOUND = EVENT_SOUND.DEFAULT) -> void:
	var sound_index := int(event_sound)
	if sound_index < 0 or sound_index >= event_sounds.size():
		push_warning("找不到 EVENT_SOUND 對應的音效：%s" % sound_index)
		return

	var stream := event_sounds[sound_index]
	if stream == null:
		push_warning("EVENT_SOUND.%s 尚未設定音效" % EVENT_SOUND.find_key(sound_index))
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
