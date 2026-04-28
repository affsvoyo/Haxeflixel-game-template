package states;

import flixel.system.FlxAssets.FlxShader;

class CustomWaveShader extends FlxShader
{
    @:glFragmentSource('
        #pragma header
		//uniform float tx, ty; // x,y waves phase
		uniform float uTime;
		
		/**
		 * How fast the waves move over time
		 */
		uniform float uSpeed;
		
		/**
		 * Number of waves over time
		 */
		uniform float uFrequency;
		
		/**
		 * How much the pixels are going to stretch over the waves
		 */
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
