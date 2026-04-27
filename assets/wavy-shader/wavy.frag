#pragma header

uniform float uTime;

const int EFFECT_TYPE_DREAMY = 1;
const int EFFECT_TYPE_WAVY = 2;
const int EFFECT_TYPE_HEAT_WAVE_HORIZONTAL = 3;
const int EFFECT_TYPE_HEAT_WAVE_VERTICAL = 4;
const int EFFECT_TYPE_FLAG = 0;

uniform int effectType;
uniform float uSpeed;
uniform float uFrequency;
uniform float uWaveAmplitude;

vec2 sineWave(vec2 pt)
{
    float x = 0.0;
    float y = 0.0;

    if (effectType == EFFECT_TYPE_DREAMY)
    {
        float offsetX = sin(pt.y * uFrequency + uTime * uSpeed) * uWaveAmplitude;
        pt.x += offsetX;
    }
    else if (effectType == EFFECT_TYPE_WAVY)
    {
        float offsetY = sin(pt.x * uFrequency + uTime * uSpeed) * uWaveAmplitude;
        pt.y += offsetY;
    }
    else if (effectType == EFFECT_TYPE_HEAT_WAVE_HORIZONTAL)
    {
        x = sin(pt.x * uFrequency + uTime * uSpeed) * uWaveAmplitude;
    }
    else if (effectType == EFFECT_TYPE_HEAT_WAVE_VERTICAL)
    {
        y = sin(pt.y * uFrequency + uTime * uSpeed) * uWaveAmplitude;
    }
    else if (effectType == EFFECT_TYPE_FLAG)
    {
        y = sin(pt.y * uFrequency + 10.0 * pt.x + uTime * uSpeed) * uWaveAmplitude;
        x = sin(pt.x * uFrequency + 5.0 * pt.y + uTime * uSpeed) * uWaveAmplitude;
    }

    return vec2(pt.x + x, pt.y + y);
}

void main()
{
    vec2 uv = sineWave(openfl_TextureCoordv);
    gl_FragColor = flixel_texture2D(bitmap, uv);
}
