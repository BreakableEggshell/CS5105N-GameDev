extends AudioStreamPlayer
## Autoload: background music that keeps playing across scene changes.

const TRACK := preload("res://assets/music_sfx/Mexico Loop.wav")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	stream = TRACK
	bus = &"Music"
	# The track is imported as looping; this is a fallback in case it isn't.
	finished.connect(play)
	play()
