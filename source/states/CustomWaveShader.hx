package states;

import flixel.system.FlxAssets.FlxShader;
import openfl.Assets;

class CustomWaveShader extends FlxShader
{
    @:glFragmentSource(Assets.getText("assets/data/shader/Wavy.frag"))
    public function new()
    {
        super();
    }
}
