package;

import openfl.display.Sprite;
import flixel.FlxGame;

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
