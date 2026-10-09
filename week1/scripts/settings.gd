extends Node
## Autoload: player settings (volume, fullscreen, key bindings). Applied on startup and saved to disk.

const PATH := "user://settings.cfg"

## Actions the player can rebind, with the name shown in the options menu.
const REBINDABLE := {
	&"move_left": "Move Left",
	&"move_right": "Move Right",
	&"move_jump": "Jump",
	&"throw": "Throw",
}

var music_volume := 1.0
var sfx_volume := 1.0
var fullscreen := false

# Bus volumes from default_bus_layout.tres; sliders scale relative to these.
var _base_db := {}
# Keys from project.godot's Input Map, used by "Reset Controls".
var _default_keys := {}

func _ready() -> void:
	for bus in [&"Music", &"SFX"]:
		_base_db[bus] = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus))
	for action in REBINDABLE:
		_default_keys[action] = get_keys(action)
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

## Physical keycodes currently bound to an action.
func get_keys(action: StringName) -> Array[int]:
	var keys: Array[int] = []
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			keys.append(event.physical_keycode if event.physical_keycode != KEY_NONE else event.keycode)
	return keys

## Display name for a physical key on the player's keyboard layout (e.g. "W", "Space").
func key_name(physical_keycode: int) -> String:
	var keycode := DisplayServer.keyboard_get_keycode_from_physical(physical_keycode)
	return OS.get_keycode_string(keycode if keycode != KEY_NONE else physical_keycode)

## Binds `action` to a single key. If another action already uses that key,
## it gets this action's old key instead, so no action is left unbound.
func rebind(action: StringName, physical_keycode: int) -> void:
	var old_keys := get_keys(action)
	var old_key: int = old_keys[0] if not old_keys.is_empty() else KEY_NONE
	for other in REBINDABLE:
		if other == action:
			continue
		var other_keys := get_keys(other)
		var index := other_keys.find(physical_keycode)
		if index == -1:
			continue
		if old_key != KEY_NONE and old_key not in other_keys:
			other_keys[index] = old_key
		else:
			other_keys.remove_at(index)
		_set_keys(other, other_keys)
	var new_keys: Array[int] = [physical_keycode]
	_set_keys(action, new_keys)

func reset_controls() -> void:
	for action in REBINDABLE:
		_set_keys(action, _default_keys[action])

func _set_keys(action: StringName, keys: Array[int]) -> void:
	# Only replace keyboard bindings; leave any other input types alone.
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			InputMap.action_erase_event(action, event)
	for key in keys:
		var event := InputEventKey.new()
		event.physical_keycode = key
		InputMap.action_add_event(action, event)

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(PATH) != OK:
		return
	music_volume = config.get_value("audio", "music_volume", music_volume)
	sfx_volume = config.get_value("audio", "sfx_volume", sfx_volume)
	fullscreen = config.get_value("display", "fullscreen", fullscreen)
	for action in REBINDABLE:
		var saved: Array = config.get_value("controls", action, [])
		if not saved.is_empty():
			var keys: Array[int] = []
			keys.assign(saved)
			_set_keys(action, keys)

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("display", "fullscreen", fullscreen)
	for action in REBINDABLE:
		config.set_value("controls", action, get_keys(action))
	config.save(PATH)

func _apply_volume(bus: StringName, value: float) -> void:
	var index := AudioServer.get_bus_index(bus)
	AudioServer.set_bus_mute(index, value <= 0.0)
	AudioServer.set_bus_volume_db(index, _base_db[bus] + linear_to_db(maxf(value, 0.001)))

func _apply_fullscreen() -> void:
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	if DisplayServer.window_get_mode() != mode:
		DisplayServer.window_set_mode(mode)
