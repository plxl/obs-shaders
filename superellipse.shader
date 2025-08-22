// superellipse (squircle / rounded rect) crop with uniform edge smoothing
// plxl: https://github.com/plxl
// what is a superellipse? https://en.wikipedia.org/wiki/Superellipse

uniform float exponent<
    string label = "Exponent (n)";
    string widget_type = "slider";
    float minimum = 1.0;
    float maximum = 24.0;
    float step = 0.1;
> = 5.0;

uniform float edge_smoothing<
    string label = "Edge smoothing (px)";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 100.0;
    float step = 0.5;
> = 5.0;


// helper functions

float superellipse_sd(float2 p, float2 center, float half, float n, float eps) {
    float2 ca = abs(p - center);
    float u = ca.x / half;
    float v = ca.y / half;
    float F = pow(u, n) + pow(v, n) - 1.0;
    float gu = (n * ((n>1.0) ? pow(max(u, eps), n - 1.0) : 1.0)) / half;
    float gv = (n * ((n>1.0) ? pow(max(v, eps), n - 1.0) : 1.0)) / half;
    float grad = sqrt(gu * gu + gv * gv);
    grad = max(grad, eps);
    return F / grad;
}

float box_sdf(float2 p, float2 center, float2 half) {
    float2 d = abs(p - center) - half;
    float2 maxd = max(d, 0.0);
    float sd_out = length(maxd);
    float sd_in = min(max(d.x, d.y), 0.0);
    return sd_out + sd_in;
}


float4 mainImage(VertData v_in) : TARGET
{
    float4 src = image.Sample(textureSampler, v_in.uv);

    // texture size in pixels and pixel coords from left/bottom
    float2 texSize = float2(1.0, 1.0) / uv_pixel_interval;
    float2 px = v_in.uv / uv_pixel_interval; // pixel coords (0..width-1, 0..height-1)

    // semi-axes (half dimensions)
    float a = max(1.0, texSize.x * 0.5);
    float b = max(1.0, texSize.y * 0.5);

    float n = max(1.0, exponent);
    float es = max(0.0, float(edge_smoothing));
    float eps = 1e-6;

    // distance to rectangle edges (in pixels) measured inward
    float dist_left   = px.x;
    float dist_right  = texSize.x - px.x;
    float dist_bottom = px.y;
    float dist_top    = texSize.y - px.y;
    float dist_rect = min(min(dist_left, dist_right), min(dist_bottom, dist_top));

    // compute signed distance (px) to the union of two square superellipse caps
    // if source is (near) square, this reduces to just one superellipse.

    float signed_dist_px = 0.0;
    bool wide = texSize.x > texSize.y + 0.5;
    bool tall = texSize.y > texSize.x + 0.5;

    if (wide) {
        float cap_half = b;
        float2 cLeft  = float2(cap_half, b);
        float2 cRight = float2(texSize.x - cap_half, b);
        float sd_left  = superellipse_sd(px, cLeft,  cap_half, n, eps);
        float sd_right = superellipse_sd(px, cRight, cap_half, n, eps);

        float2 rect_center = float2(texSize.x * 0.5, b);
        float2 rect_half   = float2(texSize.x * 0.5 - cap_half, b);
        float sd_rect = box_sdf(px, rect_center, rect_half);

        // union: nearest of left cap, right cap, or centre rectangle
        signed_dist_px = min(min(sd_left, sd_right), sd_rect);

    } else if (tall) {
        float cap_half = a;
        float2 cBottom = float2(a, cap_half);
        float2 cTop    = float2(a, texSize.y - cap_half);
        float sd_bottom = superellipse_sd(px, cBottom, cap_half, n, eps);
        float sd_top    = superellipse_sd(px, cTop,    cap_half, n, eps);

        float2 rect_center = float2(a, texSize.y * 0.5);
        float2 rect_half   = float2(a, texSize.y * 0.5 - cap_half);
        float sd_rect = box_sdf(px, rect_center, rect_half);

        signed_dist_px = min(min(sd_bottom, sd_top), sd_rect);

    } else {
        // near-square: single centred superellipse (original behaviour)
        signed_dist_px = superellipse_sd(px, float2(a, b), a, n, eps);
    }

    // inside distance to superellipse boundary (positive when inside)
    float dist_super_inside = max(0.0, -signed_dist_px);

    // nearest inside distance to any outer boundary (uniform for sides + corners)
    float inside_dist = min(dist_rect, dist_super_inside);

    // alpha: 0 at boundary/outside, ramps to 1 across es pixels inward
    float alpha;
    if (es <= 0.0) {
        alpha = (inside_dist > 0.0) ? 1.0 : 0.0;
    } else {
        alpha = smoothstep(0.0, 1.0, inside_dist / es);
    }

    // for some reason, returning a float4 like this breaks the preview
    // probably a bug with exeldro or OBS but the actual filter still works as expected
    return float4(src.rgb, src.a * alpha);
}
