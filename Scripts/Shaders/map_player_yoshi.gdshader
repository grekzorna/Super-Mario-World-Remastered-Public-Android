shader_type canvas_item;

uniform vec3 mask_1: source_color = vec3(0, 0, 0);
uniform vec3 mask_2: source_color = vec3(0, 0, 0);
uniform vec3 replace_1: source_color = vec3(0, 0, 0);
uniform vec3 replace_2: source_color = vec3(0, 0, 0);
void fragment() {
	if (vec3(COLOR.r, COLOR.g, COLOR.b) == mask_1){
		COLOR = vec4(replace_1.r, replace_1.g, replace_1.b, COLOR.a);
	}
	if (vec3(COLOR.r, COLOR.g, COLOR.b) == mask_2){
		COLOR = vec4(replace_2.r, replace_2.g, replace_2.b, COLOR.a);
	}
}
