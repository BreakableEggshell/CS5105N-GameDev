extends CanvasLayer

const HEALTH_PER_HEART := 2
const ICON_READY := Color.WHITE
const ICON_COOLDOWN := Color(0.3, 0.3, 0.3)
const ICON_EMPTY := Color(1, 1, 1, 0.4)
const COUNT_COLOR := Color(1, 0.96, 0.88)
const COUNT_EMPTY_FLASH := Color(1, 0.3, 0.3)

@onready var hearts: Array[Node] = $Hearts.get_children()
@onready var potion_icon: Sprite2D = $PotionIcon
@onready var potion_count: Label = $PotionCount
@onready var cooldown_label: Label = $CooldownLabel
@onready var tutorial_label: Label = $TutorialLabel

var throw_state: Node
## Showing "Press R to restart" because the player ran out of potions.
var _restart_hint := false
var _fade_tween: Tween

func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(_on_health_changed)
		throw_state = player.get_node_or_null("StateMachine/Throw")
	Tutorial.changed.connect(_update_tutorial)
	tutorial_label.visible = Tutorial.active and Inventory.has_potion()
	_update_tutorial()
	Inventory.changed.connect(_on_potions_changed)
	Inventory.changed.connect(func(_potions: int) -> void: _update_tutorial())
	Inventory.empty_throw_attempted.connect(_flash_empty)
	_on_potions_changed(Inventory.potions)

func _on_potions_changed(potions: int) -> void:
	potion_count.text = "x %d" % potions
	if potions > 0:
		_restart_hint = false
	elif Inventory.ran_out and not _restart_hint:
		# Wait a moment so the throw tutorial's "3/3" can show before this replaces it.
		await get_tree().create_timer(1.0, false).timeout
		if Inventory.ran_out:
			_restart_hint = true
			_update_tutorial()

## Throw pressed with no potions: flash the counter red.
func _flash_empty() -> void:
	potion_count.add_theme_color_override("font_color", COUNT_EMPTY_FLASH)
	var tween := create_tween()
	tween.tween_interval(0.25)
	tween.tween_callback(potion_count.add_theme_color_override.bind("font_color", COUNT_COLOR))

func _update_tutorial() -> void:
	# Only nag about throwing while there's actually a potion to throw.
	var keys := Settings.get_keys(&"throw").map(Settings.key_name)
	var text := "Press %s to throw potions (%d/%d)" % [
		" / ".join(keys), Tutorial.throws_done, Tutorial.THROWS_NEEDED]
	if Tutorial.active and Inventory.has_potion():
		_show_hint(text)
	elif _restart_hint:
		var restart_keys := Settings.get_keys(&"restart").map(Settings.key_name)
		_show_hint("Press %s to restart" % " / ".join(restart_keys))
	elif tutorial_label.visible:
		# Finished (shows 3/3) or out of potions: fade the hint out.
		if not Tutorial.active:
			tutorial_label.text = text
		if _fade_tween:
			_fade_tween.kill()
		_fade_tween = create_tween()
		_fade_tween.tween_property(tutorial_label, "modulate:a", 0.0, 0.6)
		_fade_tween.tween_callback(tutorial_label.hide)

func _show_hint(text: String) -> void:
	if _fade_tween:
		_fade_tween.kill()
	tutorial_label.text = text
	tutorial_label.modulate.a = 1.0
	tutorial_label.show()

func _process(_delta: float) -> void:
	if throw_state == null:
		return
	var remaining: float = throw_state.cooldown_remaining()
	var cooling := remaining > 0.0
	if cooling:
		potion_icon.modulate = ICON_COOLDOWN
	elif not Inventory.has_potion():
		potion_icon.modulate = ICON_EMPTY
	else:
		potion_icon.modulate = ICON_READY
	cooldown_label.visible = cooling
	if cooling:
		cooldown_label.text = "%.1f" % remaining

func _on_health_changed(health: int) -> void:
	for i in hearts.size():
		if is_instance_valid(hearts[i]):
			hearts[i].set_value(clampi(health - i * HEALTH_PER_HEART, 0, HEALTH_PER_HEART))
