extends Node
## Autoload: saves the player's progress (the level they've reached) to disk,
## so "Continue" on the title screen can pick up where they left off.

const PATH := "user://savegame.cfg"

## File path of the saved level, or "" if there's no save.
var saved_level := ""

func _ready() -> void:
	var config := ConfigFile.new()
	if config.load(PATH) == OK:
		var level: String = config.get_value("progress", "level", "")
		# Ignore a save pointing at a level that no longer exists.
		if ResourceLoader.exists(level):
			saved_level = level

func has_save() -> bool:
	return saved_level != ""

## Called by the player when a level starts.
func save_level(level_path: String) -> void:
	if level_path == "" or level_path == saved_level:
		return
	saved_level = level_path
	var config := ConfigFile.new()
	config.set_value("progress", "level", level_path)
	config.save(PATH)
