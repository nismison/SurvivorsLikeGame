shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.75;
uniform float smoothness : hint_range(0.0, 1.0) = 0.45;
uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float opacity : hint_range(0.0, 1.0) = 1.0; // 控制整体透明度

void fragment() {
    vec2 uv = UV * 2.0 - 1.0;
    float dist = length(uv);
    float vignette = smoothstep(intensity, intensity - smoothness, dist);
    vignette = 1.0 - vignette;

    // 最终颜色乘以透明度控制
    COLOR = vignette_color * vignette;
    COLOR.a *= opacity;
}
