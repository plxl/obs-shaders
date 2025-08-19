// edge fade: just fades alpha from any of the selected edges
// plxl: https://github.com/plxl

uniform float FadeFraction <
    string label = "Fade Fraction";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 2.0;
    float step = 0.01;
> = 0.05;

uniform bool FadeTop <string label="Fade Top";> = true;
uniform bool FadeBottom <string label="Fade Bottom";> = true;
uniform bool FadeLeft <string label="Fade Left";> = true;
uniform bool FadeRight <string label="Fade Right";> = true;

float4 mainImage(VertData v_in) : TARGET
{
    float4 color = image.Sample(textureSampler, v_in.uv);
    float alpha = 1.0;
    
    if (FadeTop)
        alpha *= smoothstep(0.0, FadeFraction, v_in.uv.y);
    if (FadeBottom)
        alpha *= smoothstep(0.0, FadeFraction, 1.0 - v_in.uv.y);
    if (FadeLeft)
        alpha *= smoothstep(0.0, FadeFraction, v_in.uv.x);
    if (FadeRight)
        alpha *= smoothstep(0.0, FadeFraction, 1.0 - v_in.uv.x);

    return float4(color.rgb, color.a * alpha);
}
