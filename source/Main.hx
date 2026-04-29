package;

import openfl.display.Sprite;
import flixel.FlxGame;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;

import states.PlayState;
import ConfigState;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

class Main extends Sprite
{
    public static var GLOBAL_FONT:String = "assets/fonts/vcr.ttf";

    public function new()
    {
        super();

        FlxTransitionableState.defaultTransIn = true;
        FlxTransitionableState.defaultTransOut = true;

        var firstState:Class<flixel.FlxState> = ConfigState;

        #if sys
        var bootPath = "assets/data/firstboot.txt";

        if (FileSystem.exists(bootPath))
        {
            var content:String = File.getContent(bootPath);

            if (content.indexOf("configured=true") != -1)
                firstState = PlayState;
        }
        #else
        firstState = ConfigState;
        #end

        addChild(new FlxGame(0, 0, firstState));
    }
}
