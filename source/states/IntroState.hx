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
    override public function create()
    {
        super.create();
        decideNextState();
    }

    function decideNextState():Void
    {
        var nextState:FlxState = new ConfigState();
        var configured:Bool = false;

        #if android
        // Mobile/Android usa assets embutidos
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
        // Desktop
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
            nextState = new PlayState();
        }

        FlxG.switchState(nextState);
    }
}                nextState = new PlayState();
            }
        }
        #end

        FlxG.switchState(nextState);
    }
}
