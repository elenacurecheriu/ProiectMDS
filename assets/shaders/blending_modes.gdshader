shader_type canvas_item;
// BLENDING MODES
vec3 multiply(vec3 base, vec3 blend) {
    return base * blend;
}
vec3 screen(vec3 base, vec3 blend) {
    return 1.0 - (1.0 - base) * (1.0 - blend);
}
vec3 darken(vec3 base, vec3 blend) {
    return min(base, blend);
}
vec3 lighten(vec3 base, vec3 blend) {
    return max(base, blend);
}
vec3 difference(vec3 base, vec3 blend) {
    return abs(base - blend);
}
vec3 exclusion(vec3 base, vec3 blend) {
    return base + blend - 2.0 * base * blend;
}
vec3 overlay(vec3 base, vec3 blend) {
    vec3 limit = step(0.5, base);
    return mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), limit);
}
vec3 hard_light(vec3 base, vec3 blend) {
    vec3 limit = step(0.5, blend);
    return mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), limit);
}
vec3 soft_light(vec3 base, vec3 blend) {
    vec3 limit = step(0.5, blend);
    return mix(2.0 * base * blend + base * base * (1.0 - 2.0 * blend), sqrt(base) * (2.0 * blend - 1.0) + (2.0 * base) * (1.0 - blend), limit);
}
vec3 color_dodge(vec3 base, vec3 blend) {
    return base / (1.0 - blend);
}
vec3 linear_dodge(vec3 base, vec3 blend) {
    return base + blend;
}
vec3 color_burn(vec3 base, vec3 blend) {
    return 1.0 - (1.0 - base) / blend;
}
vec3 linear_burn(vec3 base, vec3 blend) {
    return base + blend - 1.0;
}

//thank u claude pentru photoshop math functions

// Converts RGB to HSL
vec3 rgb_to_hsl(vec3 color) {
    float maxColor = max(max(color.r, color.g), color.b);
    float minColor = min(min(color.r, color.g), color.b);
    float delta = maxColor - minColor;
    
    float h = 0.0;
    float s = 0.0;
    float l = (maxColor + minColor) / 2.0;
    
    if (delta > 0.0) {
        s = l < 0.5 ? delta / (maxColor + minColor) : delta / (2.0 - maxColor - minColor);
        
        if (maxColor == color.r) {
            h = (color.g - color.b) / delta + (color.g < color.b ? 6.0 : 0.0);
        } else if (maxColor == color.g) {
            h = (color.b - color.r) / delta + 2.0;
        } else {
            h = (color.r - color.g) / delta + 4.0;
        }
        h /= 6.0;
    }
    
    return vec3(h, s, l);
}

// Function to help with HSL to RGB conversion
float hue_to_rgb(float p, float q, float t) {
    if (t < 0.0) t += 1.0;
    if (t > 1.0) t -= 1.0;
    if (t < 1.0/6.0) return p + (q - p) * 6.0 * t;
    if (t < 1.0/2.0) return q;
    if (t < 2.0/3.0) return p + (q - p) * (2.0/3.0 - t) * 6.0;
    return p;
}

// Converts HSL to RGB
vec3 hsl_to_rgb(vec3 hsl) {
    float h = hsl.x;
    float s = hsl.y;
    float l = hsl.z;
    
    float r, g, b;
    
    if (s == 0.0) {
        r = g = b = l; // Achromatic
    } else {
        float q = l < 0.5 ? l * (1.0 + s) : l + s - l * s;
        float p = 2.0 * l - q;
        r = hue_to_rgb(p, q, h + 1.0/3.0);
        g = hue_to_rgb(p, q, h);
        b = hue_to_rgb(p, q, h - 1.0/3.0);
    }
    
    return vec3(r, g, b);
}

// Photoshop/Krita Color mode - takes hue and saturation from blend layer, luminance from base layer
vec3 ps_color(vec3 base, vec3 blend) {
    vec3 base_hsl = rgb_to_hsl(base);
    vec3 blend_hsl = rgb_to_hsl(blend);
    
    // Take hue and saturation from blend, luminance from base
    return hsl_to_rgb(vec3(blend_hsl.x, blend_hsl.y, base_hsl.z));
}

// Hue mode - takes hue from blend layer, saturation and luminance from base
vec3 ps_hue(vec3 base, vec3 blend) {
    vec3 base_hsl = rgb_to_hsl(base);
    vec3 blend_hsl = rgb_to_hsl(blend);
    
    // Take hue from blend, saturation and luminance from base
    return hsl_to_rgb(vec3(blend_hsl.x, base_hsl.y, base_hsl.z));
}

// Saturation mode - takes saturation from blend layer, hue and luminance from base
vec3 ps_saturation(vec3 base, vec3 blend) {
    vec3 base_hsl = rgb_to_hsl(base);
    vec3 blend_hsl = rgb_to_hsl(blend);
    
    // Take saturation from blend, hue and luminance from base
    return hsl_to_rgb(vec3(base_hsl.x, blend_hsl.y, base_hsl.z));
}

// Luminosity mode - takes luminance from blend layer, hue and saturation from base
vec3 ps_luminosity(vec3 base, vec3 blend) {
    vec3 base_hsl = rgb_to_hsl(base);
    vec3 blend_hsl = rgb_to_hsl(blend);
    
    // Take luminance from blend, hue and saturation from base
    return hsl_to_rgb(vec3(base_hsl.x, base_hsl.y, blend_hsl.z));
}

// Grayscale/Black and White conversion - different methods available
vec3 grayscale_average(vec3 color) {
    float gray = (color.r + color.g + color.b) / 3.0;
    return vec3(gray);
}

vec3 grayscale_luminance(vec3 color) {
    // Human eye perceives green as brighter than red, and red as brighter than blue
    float gray = dot(color, vec3(0.299, 0.587, 0.114));
    return vec3(gray);
}

vec3 grayscale_lightness(vec3 color) {
    float gray = (max(max(color.r, color.g), color.b) + min(min(color.r, color.g), color.b)) / 2.0;
    return vec3(gray);
}

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec4 tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float opacity : hint_range(0.0, 1.0) = 1.0;
uniform int blend_mode : hint_enum("Normal", "Multiply", "Screen", "Darken", "Lighten", "Difference", "Exclusion", "Overlay", "Hard Light", "Soft Light", "Color Dodge", "Linear Dodge", "Color Burn", "Linear Burn",
							"Color", "Hue", "Saturation", "Luminosity", "Grayscale avg", "Grayscale Luminance", "Grayscale Lightness") = 0;

void fragment() {
    // Get the color behind our ColorRect (the base layer)
    vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
    
    // Our blend layer is the ColorRect with the tint applied
    vec3 blend_color = tint.rgb;
    
    // Apply the selected blending mode
    vec3 result;
    
    if (blend_mode == 0) {
        result = mix(screen_color.rgb, blend_color, opacity);
    } else if (blend_mode == 1) {
        result = mix(screen_color.rgb, multiply(screen_color.rgb, blend_color), opacity);
    } else if (blend_mode == 2) {
        result = mix(screen_color.rgb, screen(screen_color.rgb, blend_color), opacity);
    } else if (blend_mode == 3) {
        result = mix(screen_color.rgb, darken(screen_color.rgb, blend_color), opacity);
    } else if (blend_mode == 4) {
        result = mix(screen_color.rgb, lighten(screen_color.rgb, blend_color), opacity);
    } else if (blend_mode == 5) {
        result = mix(screen_color.rgb, difference(screen_color.rgb, blend_color), opacity);
    } else if (blend_mode == 6) {
        result = mix(screen_color.rgb, exclusion(screen_color.rgb, blend_color), opacity);
    } else if (blend_mode == 7) {
        result = mix(screen_color.rgb, overlay(screen_color.rgb, blend_color), opacity);
    } else if (blend_mode == 8) {
        result = mix(screen_color.rgb, hard_light(screen_color.rgb, blend_color), opacity);
    } else if (blend_mode == 9) {
        result = mix(screen_color.rgb, soft_light(screen_color.rgb, blend_color), opacity);
    } else if (blend_mode == 10) {
        result = mix(screen_color.rgb, color_dodge(screen_color.rgb, blend_color), opacity);
    } else if (blend_mode == 11) {
        result = mix(screen_color.rgb, linear_dodge(screen_color.rgb, blend_color), opacity);
    } else if (blend_mode == 12) {
        result = mix(screen_color.rgb, color_burn(screen_color.rgb, blend_color), opacity);
    } else if (blend_mode == 13) {
		result = mix(screen_color.rgb, ps_color(screen_color.rgb, blend_color), opacity);
    }else if (blend_mode == 14) {
		result = mix(screen_color.rgb, ps_hue(screen_color.rgb, blend_color), opacity);
	}else if (blend_mode == 15) {
		result = mix(screen_color.rgb, ps_saturation(screen_color.rgb, blend_color), opacity);
	}
	else if (blend_mode == 16) {
		result = mix(screen_color.rgb, ps_luminosity(screen_color.rgb, blend_color), opacity);
	}else if (blend_mode == 17) {
		result = grayscale_average(screen_color.rgb);
	}else if (blend_mode == 18) {
		result = grayscale_luminance(screen_color.rgb);
	}else if (blend_mode == 19) {
		result = grayscale_lightness(screen_color.rgb);
	}
    
    // Final output
    COLOR = vec4(result, screen_color.a * tint.a);
}