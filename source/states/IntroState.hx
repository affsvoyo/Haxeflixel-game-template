package states;

import flixel.FlxState;
import flixel.FlxG;
import flixel.util.FlxTimer;

import openfl.media.Video;
import openfl.net.NetConnection;
import openfl.net.NetStream;
import openfl.events.NetStatusEvent;
import openfl.display.Sprite;

import states.ConfigState;
import states.PlayState;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

class IntroState extends FlxState
{
    var video:Video;
    var stream:NetStream;
    var container:Sprite;

    override public function create()
    {
        super.create();

        container = new Sprite();
        FlxG.stage.addChild(container);

        var nc = new NetConnection();
        nc.connect(null);

        stream = new NetStream(nc);

        video = new Video();
        video.attachNetStream(stream);

        container.addChild(video);

        stream.client = {};
        stream.play("assets/videos/init.mp4");

        stream.addEventListener(NetStatusEvent.NET_STATUS, onStatus);
    }

    function onStatus(e:NetStatusEvent):Void
    {
        if (e.info.code == "NetStream.Play.Stop")
        {
            finish();
        }
    }

    function finish():Void
    {
        if (container != null && container.parent != null)
            FlxG.stage.removeChild(container);

        decideNextState();
    }

    function decideNextState():Void
    {
        var nextState:FlxState = new ConfigState();

        #if sys
        var bootPath:String = "assets/data/firstboot.txt";

        if (FileSystem.exists(bootPath))
        {
            var content:String = File.getContent(bootPath);

            if (content != null && content.indexOf("configured=true") != -1)
            {
                nextState = new PlayState();
            }
        }
        #end

        FlxG.switchState(nextState);
    }

    override public function destroy()
    {
        if (stream != null)
        {
            stream.close();
            stream = null;
        }

        super.destroy();
    }
}
