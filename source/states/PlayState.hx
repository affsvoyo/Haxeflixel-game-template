package states;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;

import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.UncaughtErrorEvent;
import openfl.net.FileFilter;
import openfl.display.Loader;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
import openfl.Lib;

import lime.app.Application;
import lime.ui.Window;

import shader.WiggleEffect;

#if sys
import sys.io.File;
import sys.FileSystem;
import sys.io.Process;
#end

class PlayState extends FlxState
{
    var bg:FlxSprite;
    var shader:WiggleEffect;
    var fileRef:FileReference;

    var ampText:FlxText;
    var freqText:FlxText;
    var speedText:FlxText;
    var timeText:FlxText;
    var versionText:FlxText;

    var waveAmplitude:Float = 0.1;
    var frequency:Float = 5.0;
    var speed:Float = 2.0;
    var brightness:Float = 1.0;

    var brightnessOverlay:FlxSprite;

    var uiVisible:Bool = true;
    var uiElements:Array<Dynamic> = [];

    var defaultImage:String = "assets/images/bg/cheeseburger.png";
    var currentVersion:String = "0.0.6";

    var recordBtn:FlxButton;
    var isRecording:Bool = false;
    var recordingFPS:Int = 60;
    var recordingFrames:Int = 20;

    override public function create():Void
    {
        super.create();

        initCrashHandler();
        loadSettings();

        bg = new FlxSprite();
        bg.loadGraphic(defaultImage);
        fitImageToScreen();
        add(bg);

        shader = new WiggleEffect();
        shader.uTime.value = [0.0];
        shader.uSpeed.value = [speed];
        shader.uFrequency.value = [frequency];
        shader.uWaveAmplitude.value = [waveAmplitude];

        bg.shader = shader;

        brightnessOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        brightnessOverlay.scrollFactor.set();
        add(brightnessOverlay);

        versionText = new FlxText(20, FlxG.height - 50, 500, "Version: " + currentVersion);
        add(versionText);
        uiElements.push(versionText);

        var loadBtn = new FlxButton(20, 20, "Add Image", function()
        {
            playClick();
            loadImage();
        });
        add(loadBtn);
        uiElements.push(loadBtn);

        var exitBtn = new FlxButton(FlxG.width - 100, 20, "Exit", function()
        {
            playClick();
            closeGame();
        });
        add(exitBtn);
        uiElements.push(exitBtn);

        var resetBtn = new FlxButton(20, FlxG.height - 80, "Reset", function()
        {
            playClick();
            resetDefaults();
        });
        add(resetBtn);
        uiElements.push(resetBtn);

        recordBtn = new FlxButton(20, 380, "Record MP4", function()
        {
            if (!isRecording)
                startRecording();
        });
        add(recordBtn);
        uiElements.push(recordBtn);

        ampText = new FlxText(20, 70, 400, "Wave Amplitude: " + waveAmplitude);
        add(ampText);
        uiElements.push(ampText);

        var ampMinus = new FlxButton(20, 95, "-", function()
        {
            waveAmplitude = Math.max(0, waveAmplitude - 0.005);
            updateShaderValues();
        });
        add(ampMinus);
        uiElements.push(ampMinus);

        var ampPlus = new FlxButton(120, 95, "+", function()
        {
            waveAmplitude += 0.005;
            updateShaderValues();
        });
        add(ampPlus);
        uiElements.push(ampPlus);

        freqText = new FlxText(20, 140, 400, "Frequency: " + frequency);
        add(freqText);
        uiElements.push(freqText);

        var freqMinus = new FlxButton(20, 165, "-", function()
        {
            frequency = Math.max(1, frequency - 1);
            updateShaderValues();
        });
        add(freqMinus);
        uiElements.push(freqMinus);

        var freqPlus = new FlxButton(120, 165, "+", function()
        {
            frequency += 1;
            updateShaderValues();
        });
        add(freqPlus);
        uiElements.push(freqPlus);

        speedText = new FlxText(20, 210, 400, "Speed: " + speed);
        add(speedText);
        uiElements.push(speedText);

        var speedMinus = new FlxButton(20, 235, "-", function()
        {
            speed = Math.max(0.1, speed - 0.1);
            updateShaderValues();
        });
        add(speedMinus);
        uiElements.push(speedMinus);

        var speedPlus = new FlxButton(120, 235, "+", function()
        {
            speed += 0.1;
            updateShaderValues();
        });
        add(speedPlus);
        uiElements.push(speedPlus);

        timeText = new FlxText(20, 330, 400, "Time: 0");
        add(timeText);
        uiElements.push(timeText);

        var toggleText = new FlxText(20, FlxG.height - 30, 500, "Press SPACE to toggle UI");
        add(toggleText);
        uiElements.push(toggleText);

        updateBrightness();
    }

    function initCrashHandler():Void
    {
        Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(
            UncaughtErrorEvent.UNCAUGHT_ERROR,
            function(e:UncaughtErrorEvent):Void
            {
                var errorMsg:String = e.error != null ? Std.string(e.error) : "Unknown Crash";

                #if sys
                try
                {
                    if (!FileSystem.exists("crash"))
                        FileSystem.createDirectory("crash");

                    File.saveContent(
                        "crash/playstate_crash_" + Date.now().getTime() + ".txt",
                        "Error: " + errorMsg
                    );
                }
                catch (saveError:Dynamic) {}
                #end

                FlxG.log.error("CRASH DETECTED: " + errorMsg);
            }
        );
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        shader.uTime.value[0] += elapsed;
        timeText.text = "Time: " + Std.string(Std.int(shader.uTime.value[0] * 100) / 100);

        if (FlxG.keys.justPressed.SPACE && !isRecording)
        {
            uiVisible = !uiVisible;

            for (e in uiElements)
            {
                e.visible = uiVisible;
                e.active = uiVisible;
            }
        }
    }

    function startRecording():Void
    {
        isRecording = true;

        for (e in uiElements)
        {
            e.visible = false;
            e.active = false;
        }

        #if sys
        var folder:String = "recordings";
        var output:String = folder + "/output_" + Date.now().getTime() + ".mp4";

        if (!FileSystem.exists(folder))
            FileSystem.createDirectory(folder);

        var frameCount:Int = 0;

        var timer = new FlxTimer();

        timer.start(1 / recordingFPS, function(tmr:FlxTimer)
        {
            var bmp:BitmapData = new BitmapData(FlxG.width, FlxG.height);
            bmp.draw(FlxG.stage);

            var bytes:ByteArray = bmp.encode(
                new Rectangle(0, 0, bmp.width, bmp.height),
                new PNGEncoderOptions()
            );

            File.saveBytes(
                folder + "/frame_" + StringTools.lpad("" + frameCount, "0", 5) + ".png",
                bytes
            );

            frameCount++;

            if (frameCount >= recordingFrames)
            {
                timer.cancel();
                convertFramesToVideo(folder, output);
            }

        }, recordingFrames);
        #end
    }

    function convertFramesToVideo(folder:String, output:String):Void
    {
        #if sys
        try
        {
            var ffmpeg = new Process("ffmpeg", [
                "-y",
                "-framerate", Std.string(recordingFPS),
                "-i", folder + "/frame_%05d.png",
                "-c:v", "libx264",
                "-pix_fmt", "yuv420p",
                output
            ]);

            ffmpeg.close();

            for (file in FileSystem.readDirectory(folder))
            {
                if (StringTools.endsWith(file, ".png"))
                {
                    FileSystem.deleteFile(folder + "/" + file);
                }
            }

            FlxG.log.notice("MP4 saved to: " + output);
        }
        catch (e:Dynamic)
        {
            FlxG.log.error("FFmpeg conversion failed: " + Std.string(e));
        }
        #end

        finishRecording();
    }

    function finishRecording():Void
    {
        isRecording = false;

        for (e in uiElements)
        {
            e.visible = true;
            e.active = true;
        }

        FlxG.log.notice("Recording complete!");
    }

    function resetDefaults():Void
    {
        waveAmplitude = 0.1;
        frequency = 5.0;
        speed = 2.0;
        brightness = 1.0;

        updateShaderValues();
        updateBrightness();
    }

    function updateBrightness():Void
    {
        brightnessOverlay.alpha = 1 - brightness;
    }

    function updateShaderValues():Void
    {
        shader.uWaveAmplitude.value = [waveAmplitude];
        shader.uFrequency.value = [frequency];
        shader.uSpeed.value = [speed];

        ampText.text = "Wave Amplitude: " + waveAmplitude;
        freqText.text = "Frequency: " + frequency;
        speedText.text = "Speed: " + speed;
    }

    function playClick():Void
    {
        FlxG.sound.play("assets/sounds/click.ogg");
    }

    function closeGame():Void
    {
        #if desktop
        var window:Window = Application.current.window;

        FlxTween.tween(window, {
            width: 100,
            height: 60
        }, 0.4, {
            ease: FlxEase.quadIn,
            onComplete: function(_)
            {
                #if sys
                Sys.exit(0);
                #else
                Lib.close();
                #end
            }
        });
        #end
    }

    function loadSettings():Void
    {
        var path = "assets/data/settings.txt";

        #if sys
        if (!FileSystem.exists(path))
            return;

        var lines = File.getContent(path).split("\n");

        for (line in lines)
        {
            var parts = line.split("=");

            if (parts.length < 2) continue;

            switch(parts[0])
            {
                case "waveAmplitude": waveAmplitude = Std.parseFloat(parts[1]);
                case "frequency": frequency = Std.parseFloat(parts[1]);
                case "speed": speed = Std.parseFloat(parts[1]);
            }
        }
        #end
    }

    function fitImageToScreen():Void
    {
        if (bg == null || bg.graphic == null) return;

        bg.scale.set(1, 1);
        bg.updateHitbox();

        var scaleX = FlxG.width / bg.width;
        var scaleY = FlxG.height / bg.height;
        var finalScale = Math.max(scaleX, scaleY);

        bg.scale.set(finalScale, finalScale);
        bg.updateHitbox();
        bg.screenCenter();
    }

    function loadImage():Void
    {
        fileRef = new FileReference();
        fileRef.addEventListener(Event.SELECT, onFileSelected);
        fileRef.browse([new FileFilter("Images", "*.png;*.jpg;*.jpeg")]);
    }

    function onFileSelected(e:Event):Void
    {
        fileRef.addEventListener(Event.COMPLETE, onFileLoaded);
        fileRef.load();
    }

    function onFileLoaded(e:Event):Void
    {
        var loader = new Loader();

        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(_)
        {
            var bmp:Bitmap = cast loader.content;
            bg.loadGraphic(bmp.bitmapData);
            fitImageToScreen();
            bg.shader = shader;
        });

        loader.loadBytes(fileRef.data);
    }
            } }

    function loadImage():Void
    {
        fileRef = new FileReference();
        fileRef.addEventListener(Event.SELECT, onFileSelected);
        fileRef.browse([new FileFilter("Images", "*.png;*.jpg;*.jpeg")]);
    }

    function onFileSelected(e:Event):Void
    {
        fileRef.addEventListener(Event.COMPLETE, onFileLoaded);
        fileRef.load();
    }

    function onFileLoaded(e:Event):Void
    {
        var loader = new Loader();

        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(_)
        {
            var bmp:Bitmap = cast loader.content;
            bg.loadGraphic(bmp.bitmapData);
            fitImageToScreen();
            bg.shader = shader;
        });

        loader.loadBytes(fileRef.data);
    }
}
