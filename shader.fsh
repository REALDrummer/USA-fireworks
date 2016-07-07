precision mediump float;

uniform int time;
uniform int width;
uniform int height;

const int NUMBER_OF_STREAMS = 8;
const int PARTICLES_PER_STREAM = 10;
const float PARTICLE_LIGHT_RADIUS = 5.0;
const int NUMBER_OF_FRAMES = 100;
const float GRAVITY = 9.81;

const float angle_change = 360.0 / float(NUMBER_OF_STREAMS);

void main() {
	float animation_progress = float(time) / float(NUMBER_OF_FRAMES);

	float center_x = float(width) / 2.0;
	float center_y = float(height) / 2.0;
	
	float final_diameter = min(float(width), float(height)) / 2.0;
	float diameter = final_diameter * animation_progress;
	
	/* the initial velocity of a particle used to calculate gravity */
	float v_0 = (float(final_diameter) / 2.0) / float(NUMBER_OF_FRAMES);

	/* Iterate over each particle of the firework to see how much color it adds to this pixel.
	WARNING: This could possibly be made more efficient!
	The firework particles follow paths according to evenly spaced angles on concentric circles; therefore, the number of concentric circles will be the number of particles on a stream and the number of streams will determine the angles by which the particles are positioned on the concentric circles. We then factor in gravity to determine the final position of all the circles. */
	float color_intensity = 0.0;
	for (int circle = 0; circle < PARTICLES_PER_STREAM; circle++) {
		for (float angle = 0.0; angle < 360.0; angle += angle_change) {
			/* Angle calculations are meant to start from the top, but coordinate axes start from the right; this adjusts for that difference. This prevents some shapes like pentagons from looking sideways and being vertically symmetrical instead of horizontally, which is more appealing. */
			float coordinate_angle = angle + 90.0;
			/* In addition, if there are an even number of particles, we should shift the first particle left half an angle change. */
			if (mod(float(NUMBER_OF_STREAMS), 2.0) == 0.0)
				coordinate_angle += angle_change / 2.0;
			
			float particle_circle_diameter = diameter * float(circle) / float(PARTICLES_PER_STREAM);
			
			float particle_x = center_x + particle_circle_diameter * cos(coordinate_angle);
			
			float v_0y = v_0 * sin(coordinate_angle);
			float particle_y = center_y + particle_circle_diameter * sin(coordinate_angle) + 
				/* gravity = g_y*t^2/2 + v_0y*t */ GRAVITY * pow(animation_progress, 2.0) / 2.0 + v_0y * animation_progress;
		
			vec2 particle_position = vec2(particle_x, particle_y);
		
			color_intensity += max(0.0,
				float(PARTICLE_LIGHT_RADIUS) - distance(particle_position, gl_FragCoord.xy)
			);
		}
	}
	color_intensity = min(1.0, color_intensity);
	
	// TODO TEMP: change this to a uniform of varying at some point
	const vec3 COLOR = vec3(1.0, 0.0, 0.0);

	// output pixel color
	gl_FragColor = vec4(COLOR.rgb * color_intensity, 1.0);
}
