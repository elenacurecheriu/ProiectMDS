shader_type canvas_item;

//void vertex() {
	//// Called for every vertex the material is visible on.
//}
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture , filter_linear_mipmap;
void fragment() {
	// Called for every pixel the material is visible on.
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	COLOR.rgb = vec3(COLOR.r + COLOR.g + COLOR.b) / 3.0;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
