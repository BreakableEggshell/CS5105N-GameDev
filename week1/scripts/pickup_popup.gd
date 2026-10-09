extends Node2D
## Floating "+N [icon]" text that rises and fades out, then frees itself.

var text := "+1"

@onready var label: Label = $Label

func _ready() -> void:
	label.text = text
	var tween := create_tween().set_parallel()
	tween.tween_property(self, "position:y", position.y - 14.0, 0.9).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.4).set_delay(0.5)
	tween.chain().tween_callback(queue_free)
