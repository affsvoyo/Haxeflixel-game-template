package;

import openfl.display.Sprite;
import openfl.media.Video;
import openfl.net.NetConnection;
import openfl.net.NetStream;
import openfl.events.NetStatusEvent;
import openfl.events.Event;

import flixel.FlxGame;
import flixel.FlxState;

import states.PlayState;
import ConfigState;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

class Main extends Sprite
{
    public static var GLOBAL_FONT:String = "assets/fonts/vcr.ttf";

    var video:Video;
    var nc:NetConnection;
    var ns:NetStream;

    public function new()
    {
        super();

        playIntroVideo();
    }

    function playIntroVideo():Void
    {
        nc = new NetConnection();
        nc.connect(null);

        ns = new NetStream(nc);
        ns.client = { onMetaData: function(meta:Dynamic) {} };
        ns.addEventListener(NetStatusEvent.NET_STATUS, onVideoStatus);

        video = new Video();
        video.attachNetStream(ns);
        addChild(video);

        stage.addEventListener(Event.RESIZE, onResize);
        onResize(null);

        ns.play("assets/videos/init.mp4");
    }

    function onResize(e:Event):Void
    {
        if (video != null && stage != null)
        {
            video.width = stage.stageWidth;
            video.height = stage.stageHeight;
        }
    }

    function onVideoStatus(e:NetStatusEvent):Void
    {
        if (e.info.code == "NetStream.Play.Stop")
        {
            startGame();
        }
    }

    function startGame():Void
    {
        if (video != null)
        {
            removeChild(video);
            video = null;
        }

        if (stage != null)
        {
            stage.removeEventListener(Event.RESIZE, onResize);
        }

        var firstState:Class<FlxState> = ConfigState;

        #if sys
        var bootPath:String = "assets/data/firstboot.txt";

        if (FileSystem.exists(bootPath))
        {
            var content:String = File.getContent(bootPath);

            if (content.indexOf("configured=true") != -1)
            {
                firstState = PlayState;
            }
        }
        #end

        addChild(new FlxGame(
            0,
            0,
            firstState,
            60,
            60,
            true,
            false
        ));
    }
}
