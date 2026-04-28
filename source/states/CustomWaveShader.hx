package states;

import flixel.system.FlxAssets.FlxShader;
import openfl.Assets;

class CustomWaveShader extends FlxShader
{
    public function new()
    {
        super();

        var frag:String = Assets.getText("assets/data/shader/Wavy.frag");
        this.glFragmentSource = frag;
    }
}
