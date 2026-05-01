package shader;

import flixel.system.FlxAssets.FlxShader;

class GlitchEffect extends FlxShader
{
    @:glFragmentSource('
    #pragma header

    uniform float uTime;
    uniform float uSpeed;
    uniform float uFrequency;
    uniform float uWaveAmplitude;

    vec2 sineWave(vec2 pt)
    {
        float x = 0.0;
        float y = 0.0;

        float offsetX = sin(pt.y * uFrequency + uTime * uSpeed) * (uWaveAmplitude / max(pt.x * pt.y, 0.001));
        float offsetY = sin(pt.x * uFrequency - uTime * uSpeed) * (uWaveAmplitude / max(pt.y * pt.x, 0.001));

        pt.x += offsetX;
        pt.y += offsetY;

        return vec2(pt.x + x, pt.y + y);
    }

    void main()
    {
        vec2 uv = sineWave(openfl_TextureCoordv);
        gl_FragColor = texture2D(bitmap, uv);
    }
    ')

    public function new()
    {
        super();
    }
}

class WiggleEffect extends FlxShader
{
    @:glFragmentSource('
    #pragma header

    uniform float uTime;
    uniform float uSpeed;
    uniform float uFrequency;
    uniform float uWaveAmplitude;

    vec2 sineWave(vec2 pt)
    {
        float x = 0.0;
        float y = 0.0;

        float offsetY = sin(pt.y * uFrequency + 10.0 * pt.x + uTime * uSpeed) * uWaveAmplitude;
        float offsetX = sin(pt.x * uFrequency + 5.0 * pt.y + uTime * uSpeed) * uWaveAmplitude;

        pt.y += offsetY;
        pt.x += offsetX;

        return vec2(pt.x + x, pt.y + y);
    }

    void main()
    {
        vec2 uv = sineWave(openfl_TextureCoordv);
        gl_FragColor = texture2D(bitmap, uv);
    }
    ')

    public function new()
    {
        super();
    }
}
