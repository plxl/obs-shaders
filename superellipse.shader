// superellipse (squircle / rounded rect) crop with uniform edge smoothing
// plxl: https://github.com/plxl
// what is a superellipse? https://en.wikipedia.org/wiki/Superellipse

uniform float squircle_exponent<
    string label = "Squircle exponent (n)";
    string widget_type = "slider";
    float minimum = 1.0;
    float maximum = 24.0;
    float step = 0.1;
> = 4.0;

uniform int border_thickness<
    string label = "Border thickness (px)";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 100;
    int step = 1;
> = 0;

uniform int edge_smoothing<
    string label = "Edge smoothing (px)";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 200;
    int step = 1;
> = 0;

uniform float4 border_color;

float4 mainImage(VertData v_in) : TARGET
{
    float4 src = image.Sample(textureSampler, v_in.uv);

    // texture size in pixels and pixel coords from left/bottom
    float2 texSize = float2(1.0, 1.0) / uv_pixel_interval;
    float2 px = v_in.uv / uv_pixel_interval; // pixel coords (0..width-1, 0..height-1)

    // semi-axes (half dimensions)
    float a = max(1.0, texSize.x * 0.5);
    float b = max(1.0, texSize.y * 0.5);

    float n = max(1.0, squircle_exponent);
    float es = max(0.0, float(edge_smoothing));
    float bt = max(0.0, float(border_thickness));
    float eps = 1e-6;

    // distance to rectangle edges (in pixels) measured inward
    float dist_left   = px.x;
    float dist_right  = texSize.x - px.x;
    float dist_bottom = px.y;
    float dist_top    = texSize.y - px.y;
    float dist_rect = min(min(dist_left, dist_right), min(dist_bottom, dist_top));

    // centred absolute coords (first-quadrant equiv) in pixels
    float2 centeredAbs = abs(px - float2(a, b));

    // normalised u,v in [0..1] from centre toward outer edges
    float u = centeredAbs.x / a;
    float v = centeredAbs.y / b;

    // F = u^n + v^n - 1  (<=0 inside)
    float Au = pow(u, n);
    float Av = pow(v, n);
    float F = Au + Av - 1.0;

    // gradient magnitude of F in pixel units (safe for n>=1)
    float gu = (n * ( (n>1.0) ? pow(max(u, eps), n - 1.0) : 1.0 )) / a;
    float gv = (n * ( (n>1.0) ? pow(max(v, eps), n - 1.0) : 1.0 )) / b;
    float grad_mag = sqrt(gu * gu + gv * gv);
    if (grad_mag < eps) grad_mag = eps;

    // signed distance to superellipse boundary in pixels (positive outside)
    float signed_dist_px = F / grad_mag;

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

    // border is outside the superellipse boundary within bt pixels
    bool is_within_border = (signed_dist_px > 0.0 && signed_dist_px <= bt);
    float4 borderMask = is_within_border ? border_color : float4(0,0,0,0);

    return src * alpha + borderMask;
}
