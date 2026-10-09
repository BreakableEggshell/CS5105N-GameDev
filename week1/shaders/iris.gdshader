shader_type canvas_item;
// Black screen with a transparent circle "hole" (the iris).

// Circle centre and radius, in pixels of the rect this is drawn on.
uniform vec2 center = vec2(0.0);
uniform float radius = 2000.0;
// Size of the rect in pixels (UV is 0-1, so this converts it back to pixels).
uniform vec2 rect_size = vec2(1152.0, 648.0);

void fragment() {
	float dist = length(UV * rect_size - center);
	COLOR = vec4(0.0, 0.0, 0.0, dist > radius ? 1.0 : 0.0);
}
