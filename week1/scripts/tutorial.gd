extends Node
## Autoload: the "throw potions" tutorial hint. Armed by the title screen's Start
## button and shown once the player first picks up potions in the first level;
## progress survives restarts of that level. Leaving the first level ends it.

signal changed

const THROWS_NEEDED := 3
## The tutorial only runs on this level.
const LEVEL := "res://scene/main.tscn"

## Start was pressed, waiting for the first potion pickup.
var pending := false
var active := false
var throws_done := 0

func arm() -> void:
	pending = true
	active = false
	throws_done = 0
	changed.emit()

## File path of the level being played (set by the player when a level starts).
var _current_level := ""

## Called when the player picks up potions.
func on_potions_collected() -> void:
	if not pending or not in_tutorial_level():
		return
	pending = false
	active = true
	changed.emit()

## Called by the player when a level starts. Reaching any other level ends the tutorial.
func on_level_started(level_path: String) -> void:
	_current_level = level_path
	if (pending or active) and not in_tutorial_level():
		pending = false
		active = false
		changed.emit()

func in_tutorial_level() -> bool:
	return _current_level == LEVEL

func register_throw() -> void:
	if not active:
		return
	throws_done += 1
	if throws_done >= THROWS_NEEDED:
		active = false
	changed.emit()
