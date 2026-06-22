shader_type spatial;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float t = TIME / 10.;
	ALBEDO = floor(fract(VERTEX + t) * 5.0)/5.0;
	ALBEDO *= 0.5;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
