package states;

import flixel.FlxState;
import flixel.FlxG;

import openfl.display.Sprite;
import openfl.media.Video;
import openfl.net.NetConnection;
import openfl.net.NetStream;
import openfl.events.NetStatusEvent;

import states.ConfigState;
import states.PlayState;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

class IntroState extends FlxState
{
    var videoLayer:Sprite;
    var video:Video;
    var stream:NetStream;

    override public function create()
    {
        super.create();

        // layer separada do Flixel (necessário para vídeo)
        videoLayer = new Sprite();
        FlxG.stage.addChild(videoLayer);

        // conexão de vídeo
        var nc = new NetConnection();
        nc.connect(null);

        stream = new NetStream(nc);

        // vídeo
        video = new Video();
        video.attachNetStream(stream);

        videoLayer.addChild(video);

        // evento de fim
        stream.addEventListener(NetStatusEvent.NET_STATUS, onStatus);

        // inicia vídeo
        stream.play("assets/videos/init.mp4");
    }

    function onStatus(e:NetStatusEvent):Void
    {
        if (e.info != null && e.info.code == "NetStream.Play.Stop")
        {
            finishIntro();
        }
    }

    function finishIntro():Void
    {
        cleanupVideo();
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

    function cleanupVideo():Void
    {
        if (stream != null)
        {
            try stream.close() catch(e:Dynamic) {}
            stream = null;
        }

        if (videoLayer != null)
        {
            if (videoLayer.parent != null)
                FlxG.stage.removeChild(videoLayer);

            videoLayer = null;
        }

        video = null;
    }

    override public function destroy()
    {
        cleanupVideo();
        super.destroy();
    }
}
