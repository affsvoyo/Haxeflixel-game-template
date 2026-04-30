package states;

import flixel.FlxState;
import flixel.FlxG;
import hxcodec.flixel.FlxVideo;
import states.ConfigState;
import states.PlayState;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

class IntroState extends FlxState
{
    override public function create():Void
    {
        super.create();

        var video = new FlxVideo();
        
        video.onEndReached.add(function() {
            decideNextState();
        });

        video.play("assets/videos/init.mp4");
    }

    function decideNextState():Void
    {
        var nextState:FlxState = new ConfigState();

        #if sys
        var bootPath:String = "assets/data/firstboot.txt";

        if (FileSystem.exists(bootPath))
        {
            var content:String = File.getContent(bootPath);

            if (content.indexOf("configured=true") != -1)
            {
                nextState = new PlayState();
            }
        }
        #end

        FlxG.switchState(nextState);
    }
}
