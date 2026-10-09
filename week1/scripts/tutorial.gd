extends Node
## Autoload: the "throw potions" tutorial hint. Started by the title screen's Start
## button; progress survives level restarts and changes until it's finished.

signal changed

const THROWS_NEEDED := 3

var active := false
var throws_done := 0

func start() -> void:
	active = true
	throws_done = 0
	changed.emit()

func register_throw() -> void:
	if not active:
		return
	throws_done += 1
	if throws_done >= THROWS_NEEDED:
		active = false
	changed.emit()
