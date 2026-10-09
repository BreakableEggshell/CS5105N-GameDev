extends Node2D
## Sky background drawn from the world tileset's gradient column (atlas 0,9 to 0,15).
## Always fills the camera view; the gradient stays centred vertically on screen
## and scrolls slowly sideways for a bit of depth.

const TILE := 16.0

@export var tileset: Texture2D
## Top-left of the gradient column in the tileset, in pixels (atlas 0,9).
@export var column_origin := Vector2(0, 144)
## Number of tiles in the gradient column (atlas rows 9 to 15).
@export var column_tiles := 7
## 0 = background stays still on screen, 1 = moves with the world.
@export_range(0.0, 1.0) var scroll_scale := 0.2

var _view_size := Vector2.ZERO
var _shift := 0.0

func _process(_delta: float) -> void:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return
	var center := cam.get_screen_center_position()
	_view_size = get_viewport_rect().size / cam.zoom
	var top_left := center - _view_size / 2.0
	global_position = top_left
	# How far the tile pattern has scrolled, wrapped to one tile width.
	_shift = fposmod(top_left.x * scroll_scale, TILE)
	queue_redraw()

func _draw() -> void:
	if tileset == null or _view_size == Vector2.ZERO:
		return
	var column_height := column_tiles * TILE
	var sky_top := floorf((_view_size.y - column_height) / 2.0)
	var sky_bottom := sky_top + column_height
	var top_fill := Rect2(column_origin, Vector2(TILE, TILE))
	var bottom_fill := Rect2(column_origin + Vector2(0, column_height - TILE), Vector2(TILE, TILE))
	var column := Rect2(column_origin, Vector2(TILE, column_height))

	var x := -_shift
	while x < _view_size.x:
		if sky_top > 0.0:
			draw_texture_rect_region(tileset, Rect2(x, 0, TILE, sky_top), top_fill)
		draw_texture_rect_region(tileset, Rect2(x, sky_top, TILE, column_height), column)
		if sky_bottom < _view_size.y:
			draw_texture_rect_region(tileset, Rect2(x, sky_bottom, TILE, _view_size.y - sky_bottom), bottom_fill)
		x += TILE
