package states;

import flixel.FlxState;
import flixel.FlxG;

import states.ConfigState;
import states.PlayState;

import openfl.Assets;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

class IntroState extends FlxState
{
    override public function create():Void
    {
        super.create();
        decideNextState();
    }

    function decideNextState():Void
    {
        var configured:Bool = false;

        #if mobile
        if (FlxG.save.data.configured != null && FlxG.save.data.configured == true)
        {
            configured = true;
        }

        #elseif android
        var bootPath:String = "assets/data/firstboot.txt";

        if (Assets.exists(bootPath))
        {
            var content:String = Assets.getText(bootPath);

            if (content != null && content.indexOf("configured=true") != -1)
            {
                configured = true;
            }
        }

        #elseif sys
        var bootPath:String = "assets/data/firstboot.txt";

        if (FileSystem.exists(bootPath))
        {
            var content:String = File.getContent(bootPath);

            if (content != null && content.indexOf("configured=true") != -1)
            {
                configured = true;
            }
        }
        #end

        if (configured)
        {
            FlxG.switchState(new PlayState());
        }
        else
        {
            FlxG.switchState(new ConfigState());
        }
    }
}
