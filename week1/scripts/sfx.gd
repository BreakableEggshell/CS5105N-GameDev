extends Node
## Autoload: plays one-shot sound effects on the SFX bus.
## Sounds live here, so they keep playing even if the node that triggered them
## is freed or the level changes (e.g. chest opening, enemy dying).

func play(stream: AudioStream) -> void:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = &"SFX"
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
