extends Node
## Autoload: how many potions the player is carrying. Every level (and every
## restart of a level) starts with 0; potions don't carry over.

signal changed(potions: int)
## Throw was pressed with no potions (the HUD flashes the counter).
signal empty_throw_attempted

var potions := 0
## True once the player has thrown their last potion (cleared on pickup or level start).
var ran_out := false

## Empties the inventory. Called on a new game, when a level starts, and before a restart.
func reset() -> void:
	potions = 0
	ran_out = false
	changed.emit(potions)

## Called when a level starts: potions don't carry over between levels.
func begin_level() -> void:
	reset()

## Called when the player dies or restarts, before the level reloads.
func restore_level_start() -> void:
	reset()

## Adds potions (there's no carry limit). Returns how many were added.
func add(amount: int) -> int:
	if amount > 0:
		potions += amount
		ran_out = false
		changed.emit(potions)
	return maxi(amount, 0)

func has_potion() -> bool:
	return potions > 0

func use_potion() -> void:
	if potions > 0:
		potions -= 1
		ran_out = potions == 0
		changed.emit(potions)
