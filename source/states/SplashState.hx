package states;

import flixel.system.FlxSplash;
import flixel.FlxG;

class SplashState extends FlxSplash
{
    var splashTimer:Float = 0;

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        splashTimer += elapsed;

        if (splashTimer >= 4)
        {
            FlxG.switchState(new IntroState());
        }
    }
}
