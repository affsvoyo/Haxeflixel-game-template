package;

import openfl.display.Sprite;
import flixel.FlxGame;
import states.IntroState;
class Main extends Sprite
{
    public static var GLOBAL_FONT:String = "assets/fonts/vcr.ttf";

    public function new()
    {
        super();
        
        // Inicia o jogo diretamente no IntroState.
        // É lá que o vídeo será tocado e a decisão será tomada.
        addChild(new FlxGame(0, 0, IntroState, 60, 60, true, false));
    }
}
