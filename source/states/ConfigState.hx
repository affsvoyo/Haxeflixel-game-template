package states;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import openfl.Lib;
import openfl.events.UncaughtErrorEvent;
import states.PlayState;
import shader.GlitchEffect;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

class ConfigState extends FlxState
{
    var bg:FlxSprite;
    var shader:GlitchEffect;
    var waveAmplitude:Float = 0.1;
    var frequency:Float = 5.0;
    var speed:Float = 2.0;
    var uiVisible:Bool = true;

    var waveAmplitude2:Float = 0.1;
    var frequency2:Float = 5.0;
    var speed2:Float = 2.0;

    var ampText:FlxText;
    var freqText:FlxText;
    var speedText:FlxText;

    override public function create():Void
    {
        super.create();

        initCrashHandler();

        bg = new FlxSprite();
        bg.loadGraphic("assets/images/Init/Initbg.png");
        bg.screenCenter();
        add(bg);

        shader = new GlitchEffect();
        shader.uTime.value = [0.0];
        shader.uSpeed.value = [speed2];
        shader.uFrequency.value = [frequency2];
        shader.uWaveAmplitude.value = [waveAmplitude2];

        bg.shader = shader;

        #if mobile
        FlxG.resizeGame(1280, 720);
        #end

        var title:FlxText = new FlxText(20, 20, 800, "Shader Default Settings");
        title.size = 24;
        add(title);

        ampText = new FlxText(20, 80, 500, "Wave Amplitude: " + waveAmplitude);
        add(ampText);

        add(new FlxButton(20, 120, "Amplitude +", function()
        {
            waveAmplitude += 0.01;
            updateTexts();
        }));

        add(new FlxButton(220, 120, "Amplitude -", function()
        {
            waveAmplitude = Math.max(0, waveAmplitude - 0.01);
            updateTexts();
        }));

        freqText = new FlxText(20, 180, 500, "Frequency: " + frequency);
        add(freqText);

        add(new FlxButton(20, 220, "Frequency +", function()
        {
            frequency += 1;
            updateTexts();
        }));

        add(new FlxButton(220, 220, "Frequency -", function()
        {
            frequency = Math.max(1, frequency - 1);
            updateTexts();
        }));

        speedText = new FlxText(20, 280, 500, "Speed: " + speed);
        add(speedText);

        add(new FlxButton(20, 320, "Speed +", function()
        {
            speed += 0.1;
            updateTexts();
        }));

        add(new FlxButton(220, 320, "Speed -", function()
        {
            speed = Math.max(0.1, speed - 0.1);
            updateTexts();
        }));

        add(new FlxButton(20, 430, "Save Settings", saveSettings));
        add(new FlxButton(260, 430, "Finish Setup", completeSetup));

        #if !mobile
        add(new FlxButton(20, 500, "Reset First Boot", function()
        {
            var bootPath:String = "assets/data/firstboot.txt";

            #if sys
            if (FileSystem.exists(bootPath))
                FileSystem.deleteFile(bootPath);
            #end
        }));
        #end
    }

    function initCrashHandler():Void
    {
        Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(
            UncaughtErrorEvent.UNCAUGHT_ERROR,
            function(e:UncaughtErrorEvent):Void
            {
                var errorMsg:String = "Unknown Crash";

                if (e.error != null)
                    errorMsg = Std.string(e.error);

                #if sys
                try
                {
                    if (!FileSystem.exists("crash"))
                        FileSystem.createDirectory("crash");

                    var crashLog:String =
                        "Crash Report\n" +
                        "====================\n" +
                        "Error: " + errorMsg + "\n" +
                        "State: ConfigState\n";

                    File.saveContent("crash/crash_" + Date.now().getTime() + ".txt", crashLog);
                }
                catch (saveError:Dynamic) {}
                #end

                FlxG.log.error("CRASH DETECTED: " + errorMsg);
            }
        );
    }

    function updateTexts():Void
    {
        ampText.text = "Wave Amplitude: " + waveAmplitude;
        freqText.text = "Frequency: " + frequency;
        speedText.text = "Speed: " + speed;

        shader.uWaveAmplitude.value = [waveAmplitude];
        shader.uFrequency.value = [frequency];
        shader.uSpeed.value = [speed];
    }

    function saveSettings():Void
    {
        var content:String =
            "waveAmplitude=" + waveAmplitude + "\n" +
            "frequency=" + frequency + "\n" +
            "speed=" + speed + "\n" +
            "uiVisible=" + uiVisible;

        #if sys
        #if !mobile
        File.saveContent("assets/data/settings.txt", content);
        #end
        #end
    }

    function completeSetup():Void
    {
        saveSettings();

        #if sys
        #if !mobile
        File.saveContent("assets/data/firstboot.txt", "configured=true");
        #end
        #end

        FlxG.switchState(new PlayState());
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        shader.uTime.value[0] += elapsed;
    }
}