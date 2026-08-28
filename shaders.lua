local Shaders = {}

-- - Crt Effect Shader - --
Shaders.crt = love.graphics.newShader[[
    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
        // Fish eye warping //
        vec2 center = vec2(0.5);
        vec2 offset = texture_coords - center;
        offset *= 0.8;

        float distance = length(offset);
        float warp = distance * distance;
        offset *= 1.0 + warp / 5.0;

        vec2 warpedCoords = clamp(center + offset, 0.0, 1.0);
        vec4 pixel = Texel(tex, warpedCoords);

        // Scanlines //
        pixel *= color;

        float scanline = (sin(warpedCoords.y * 750.0) + 1.0) / 2.0;
        scanline = mix(0.6, 1.0, scanline); // making the scanlines less dark
        pixel.rgb += scanline * 0.06;

        return pixel;
    }
]]

return Shaders
