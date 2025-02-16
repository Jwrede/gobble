shader_type canvas_item;

uniform bool use_outline_shader = true;
uniform int width: hint_range(0, 5, 1);
uniform vec4 outline_color: source_color;
uniform float flickering_speed: hint_range(0.0, 50.0, 1.0);
uniform float minimal_flickering_alpha: hint_range(0.0, 0.9, 0.1);
uniform bool hitflash = false;

void fragment() {
    vec4 previous_color = texture(TEXTURE, UV);
    vec4 final_color = previous_color; // default result
    
    if (use_outline_shader) {
        float pixel_size_x = 1.0 / float(textureSize(TEXTURE, 0).x);
        float pixel_size_y = 1.0 / float(textureSize(TEXTURE, 0).y);
        vec2 pixel_size = vec2(pixel_size_x, pixel_size_y);
        bool foundOutline = false;
        
        // Only check for outline if the current pixel is transparent.
        if (previous_color.a == 0.0) {
            for (int x = -width; x <= width; x++) {
                for (int y = -width; y <= width; y++) {
                    vec2 pixel_offset = vec2(float(x), float(y));
                    if (texture(TEXTURE, UV + (pixel_offset * pixel_size)).a > 0.0) {
                        vec4 resulting_color = outline_color;
                        float alpha_norm = (sin(TIME * flickering_speed) + 1.2) * 0.5;
                        alpha_norm = (1.0 - minimal_flickering_alpha) * alpha_norm + minimal_flickering_alpha;
                        resulting_color.a = alpha_norm;
                        final_color = resulting_color;
                        foundOutline = true;
                        break; // Break the inner loop.
                    }
                }
                if (foundOutline) {
                    break; // Break the outer loop if an outline was found.
                }
            }
        }
    } else {
        // White effect shader.
        vec4 white_color = vec4(1.0, 1.0, 1.0, previous_color.a);
        if (hitflash) {
            final_color = white_color;
        }
    }
    
    COLOR = final_color;
}
