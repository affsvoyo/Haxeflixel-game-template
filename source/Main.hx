package;

import openfl.display.Sprite;
import flixel.FlxGame;

import states.SplashState;

class Main extends Sprite
{
    public static var GLOBAL_FONT:String = "assets/fonts/vcr.ttf";

    public function new()
    {
        super();
        addChild(new FlxGame(0, 0, SplashState, 60, 60, true));
    }
}
