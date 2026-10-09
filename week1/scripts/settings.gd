extends Node
## Autoload: player settings (volume, fullscreen). Applied on startup and saved to disk.

const PATH := "user://settings.cfg"

var music_volume := 1.0
var sfx_volume := 1.0
var fullscreen := false

# Bus volumes from default_bus_layout.tres; sliders scale relative to these.
var _base_db := {}

func _ready() -> void:
	for bus in [&"Music", &"SFX"]:
		_base_db[bus] = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus))
	load_settings()
	_apply_volume(&"Music", music_volume)
	_apply_volume(&"SFX", sfx_volume)
	_apply_fullscreen()

func set_music_volume(value: float) -> void:
	music_volume = value
	_apply_volume(&"Music", value)

func set_sfx_volume(value: float) -> void:
	sfx_volume = value
	_apply_volume(&"SFX", value)

func set_fullscreen(value: bool) -> void:
	fullscreen = value
	_apply_fullscreen()

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(PATH) != OK:
		return
	music_volume = config.get_value("audio", "music_volume", music_volume)
	sfx_volume = config.get_value("audio", "sfx_volume", sfx_volume)
	fullscreen = config.get_value("display", "fullscreen", fullscreen)

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("display", "fullscreen", fullscreen)
	config.save(PATH)

func _apply_volume(bus: StringName, value: float) -> void:
	var index := AudioServer.get_bus_index(bus)
	AudioServer.set_bus_mute(index, value <= 0.0)
	AudioServer.set_bus_volume_db(index, _base_db[bus] + linear_to_db(maxf(value, 0.001)))

func _apply_fullscreen() -> void:
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	if DisplayServer.window_get_mode() != mode:
		DisplayServer.window_set_mode(mode)
