extends Node2D

func _ready() -> void:
	for child in get_children():
		if child is CPUParticles2D:
			child.emitting = true
	# Wait for the longest-lived burst to finish before cleaning up.
	await get_tree().create_timer(1.0).timeout
	queue_free()
