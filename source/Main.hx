package;

import openfl.display.Sprite;
import flixel.FlxGame;
import flixel.system.FlxSplash;

class Main extends Sprite
{
    public static var GLOBAL_FONT:String = "assets/fonts/vcr.ttf";

    public function new()
    {
        super();

        FlxSplash.nextState = states.IntroState;

        var game:FlxGame = new FlxGame(
            0,
            0,
            FlxSplash,
            60,
            60,
            true
        );

        addChild(game);
    }
}
