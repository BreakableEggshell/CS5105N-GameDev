extends CanvasLayer

const HEALTH_PER_HEART := 2
const ICON_READY := Color.WHITE
const ICON_COOLDOWN := Color(0.3, 0.3, 0.3)

@onready var hearts: Array[Node] = $Hearts.get_children()
@onready var potion_icon: Sprite2D = $PotionIcon
@onready var cooldown_label: Label = $CooldownLabel
@onready var tutorial_label: Label = $TutorialLabel

var throw_state: Node

func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(_on_health_changed)
		throw_state = player.get_node_or_null("StateMachine/Throw")
	Tutorial.changed.connect(_update_tutorial)
	tutorial_label.visible = Tutorial.active
	_update_tutorial()

func _update_tutorial() -> void:
	if Tutorial.active:
		var keys := Settings.get_keys(&"throw").map(Settings.key_name)
		tutorial_label.text = "Press %s to throw potions (%d/%d)" % [
			" / ".join(keys), Tutorial.throws_done + 1, Tutorial.THROWS_NEEDED]
		tutorial_label.modulate.a = 1.0
		tutorial_label.show()
	elif tutorial_label.visible:
		# Just finished: fade the hint out.
		var tween := create_tween()
		tween.tween_property(tutorial_label, "modulate:a", 0.0, 0.6)
		tween.tween_callback(tutorial_label.hide)

func _process(_delta: float) -> void:
	if throw_state == null:
		return
	var remaining: float = throw_state.cooldown_remaining()
	var cooling := remaining > 0.0
	potion_icon.modulate = ICON_COOLDOWN if cooling else ICON_READY
	cooldown_label.visible = cooling
	if cooling:
		cooldown_label.text = "%.1f" % remaining

func _on_health_changed(health: int) -> void:
	for i in hearts.size():
		if is_instance_valid(hearts[i]):
			hearts[i].set_value(clampi(health - i * HEALTH_PER_HEART, 0, HEALTH_PER_HEART))
