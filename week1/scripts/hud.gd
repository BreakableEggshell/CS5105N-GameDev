extends CanvasLayer

const HEALTH_PER_HEART := 2
const ICON_READY := Color.WHITE
const ICON_COOLDOWN := Color(0.3, 0.3, 0.3)

@onready var hearts: Array[Node] = $Hearts.get_children()
@onready var potion_icon: Sprite2D = $PotionIcon
@onready var cooldown_label: Label = $CooldownLabel

var throw_state: Node

func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(_on_health_changed)
		throw_state = player.get_node_or_null("StateMachine/Throw")

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
