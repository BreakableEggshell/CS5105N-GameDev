extends Node
## Autoload: plays one-shot sound effects on the SFX bus.
## Sounds live here, so they keep playing even if the node that triggered them
## is freed or the level changes (e.g. chest opening, enemy dying).

## `volume_db` adjusts just this sound (negative = quieter, e.g. -6 is about half as loud).
func play(stream: AudioStream, volume_db := 0.0) -> void:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db
	player.bus = &"SFX"
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
