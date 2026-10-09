extends CanvasLayer
## Autoload: iris screen transition. Closes a black circle onto a point on screen
## (iris out) and opens it again (iris in). Lives outside the levels, so it stays
## closed across a level reload.

const IRIS_SHADER := preload("res://shaders/iris.gdshader")

## True while the screen is covered (after an iris out, before the iris in).
var closed := false

var _rect: ColorRect
var _material: ShaderMaterial

func _ready() -> void:
	layer = 50
	process_mode = Node.PROCESS_MODE_ALWAYS
	_material = ShaderMaterial.new()
	_material.shader = IRIS_SHADER
	_rect = ColorRect.new()
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.material = _material
	_rect.hide()
	add_child(_rect)

## Shrink the visible circle down to `screen_point` until the screen is black.
func iris_out(screen_point: Vector2, duration := 0.7) -> void:
	closed = true
	_set_center(screen_point)
	_rect.show()
	var tween := create_tween()
	tween.tween_method(_set_radius, _full_radius(screen_point), 0.0, duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	await tween.finished

## Grow the circle out from `screen_point` until the screen is fully visible.
func iris_in(screen_point: Vector2, duration := 0.6) -> void:
	_set_center(screen_point)
	_rect.show()
	var tween := create_tween()
	tween.tween_method(_set_radius, 0.0, _full_radius(screen_point), duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	_rect.hide()
	closed = false

func _set_center(screen_point: Vector2) -> void:
	_material.set_shader_parameter("center", screen_point)
	_material.set_shader_parameter("rect_size", _rect.size)

func _set_radius(radius: float) -> void:
	_material.set_shader_parameter("radius", radius)

## Radius big enough to uncover the whole screen from this point.
func _full_radius(screen_point: Vector2) -> float:
	var size := _rect.size
	var corners := [Vector2.ZERO, Vector2(size.x, 0), Vector2(0, size.y), size]
	var farthest := 0.0
	for corner in corners:
		farthest = maxf(farthest, screen_point.distance_to(corner))
	return farthest + 2.0
