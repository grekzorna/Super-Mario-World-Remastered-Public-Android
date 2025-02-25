shader_type canvas_item;

uniform vec4 og_1: source_color;
uniform vec4 og_2: source_color;
uniform vec4 og_3: source_color;
uniform vec4 og_arm: source_color;
uniform vec4 og_arm_2: source_color;

uniform vec4 colour_1: source_color;
uniform vec4 colour_2: source_color;
uniform vec4 colour_3: source_color;
uniform vec4 arm_colour: source_color;
uniform vec4 arm_2_colour: source_color;
uniform float alpha = 1.0;
uniform float epsilon = 0.001;

bool check(vec4 current_colour, vec4 old_colour, vec4 new_colour){
	return (
		current_colour.r >= old_colour.r - epsilon &&
		current_colour.r <= old_colour.r + epsilon &&

		current_colour.g >= old_colour.g - epsilon &&
		current_colour.g <= old_colour.g + epsilon &&

		current_colour.b >= old_colour.b - epsilon &&
		current_colour.b <= old_colour.b + epsilon &&

		current_colour.a != 0.0
	);
}

void fragment() {
	if (check(COLOR, og_1, colour_1)){
		COLOR = colour_1;
	}

	else if (check(COLOR, og_2, colour_2)){
		COLOR = colour_2;
	}

	else if (check(COLOR, og_3, colour_3)){
		COLOR = colour_3;
	}

	else if (check(COLOR, og_arm, arm_colour)){
		COLOR = arm_colour;
	}
	else if (check(COLOR, og_arm_2, arm_2_colour)){
		COLOR = arm_2_colour;
	}
	if (COLOR.a != 0.0)
	{
		COLOR.a = alpha;
	}
}