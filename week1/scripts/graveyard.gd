extends Node
## Autoload: remembers where the player died in the current level, so tombstones
## stay there across respawns. Forgotten when the player reaches a different
## level, starts a new game, or closes the game.

const TOMBSTONE := preload("res://scene/tombstone.tscn")

var _level := ""
var _positions: Array[Vector2] = []

## New game (Start pressed on the title screen).
func clear() -> void:
	_level = ""
	_positions.clear()

## Called by the player when a level starts: restores this level's tombstones.
func on_level_started(level: Node) -> void:
	if level.scene_file_path != _level:
		_level = level.scene_file_path
		_positions.clear()
	for pos in _positions:
		_spawn(level, pos, false)

## Records a death at `ground_position` (a point on the ground) and drops a tombstone there.
func add_tombstone(level: Node, ground_position: Vector2) -> void:
	_positions.append(ground_position)
	_spawn(level, ground_position, true)

func _spawn(level: Node, ground_position: Vector2, drop: bool) -> void:
	var tombstone: Node2D = TOMBSTONE.instantiate()
	tombstone.position = ground_position
	level.add_child(tombstone, true)  # readable names: Tombstone, Tombstone2, ...
	if drop:
		tombstone.drop()
