package states;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import openfl.Lib;
import openfl.events.UncaughtErrorEvent;
import openfl.utils.Assets;

import states.PlayState;
import shader.Shaders;

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

    var ampText:FlxText;
    var freqText:FlxText;
    var speedText:FlxText;

    override public function create():Void
    {
        super.create();

        #if sys
        if (!FileSystem.exists("assets/crash"))
            FileSystem.createDirectory("assets/crash");
        #end

        initCrashHandler();

        #if mobile
        FlxG.resizeGame(1280, 720);
        #end

        bg = new FlxSprite();
        bg.loadGraphic("assets/images/Init/Initbg.png");
        bg.screenCenter();
        add(bg);

        shader = new GlitchEffect();
        shader.uTime.value = [0.0];
        shader.uSpeed.value = [speed];
        shader.uFrequency.value = [frequency];
        shader.uWaveAmplitude.value = [waveAmplitude];

        bg.shader = shader;

        var title:FlxText = new FlxText(20, 20, 800, "Shader Default Settings");
        title.size = 24;
        add(title);

        ampText = new FlxText(20, 80, 500, "");
        freqText = new FlxText(20, 180, 500, "");
        speedText = new FlxText(20, 280, 500, "");

        add(ampText);
        add(freqText);
        add(speedText);

        createButtons();
        updateTexts();
    }

    function createButtons():Void
    {
        var spacing:Int = #if mobile 80 #else 40 #end;
        var buttonScale:Float = #if mobile 1.5 #else 1.0 #end;

        var ampPlus = new FlxButton(20, 120, "Amplitude +", function()
        {
            waveAmplitude += 0.01;
            updateTexts();
        });

        var ampMinus = new FlxButton(220, 120, "Amplitude -", function()
        {
            waveAmplitude = Math.max(0, waveAmplitude - 0.01);
            updateTexts();
        });

        var freqPlus = new FlxButton(20, 220, "Frequency +", function()
        {
            frequency += 1;
            updateTexts();
        });

        var freqMinus = new FlxButton(220, 220, "Frequency -", function()
        {
            frequency = Math.max(1, frequency - 1);
            updateTexts();
        });

        var speedPlus = new FlxButton(20, 320, "Speed +", function()
        {
            speed += 0.1;
            updateTexts();
        });

        var speedMinus = new FlxButton(220, 320, "Speed -", function()
        {
            speed = Math.max(0.1, speed - 0.1);
            updateTexts();
        });

        var saveBtn = new FlxButton(20, 430, "Save Settings", saveSettings);
        var finishBtn = new FlxButton(260, 430, "Finish Setup", completeSetup);

        scaleButton(ampPlus, buttonScale);
        scaleButton(ampMinus, buttonScale);
        scaleButton(freqPlus, buttonScale);
        scaleButton(freqMinus, buttonScale);
        scaleButton(speedPlus, buttonScale);
        scaleButton(speedMinus, buttonScale);
        scaleButton(saveBtn, buttonScale);
        scaleButton(finishBtn, buttonScale);

        add(ampPlus);
        add(ampMinus);
        add(freqPlus);
        add(freqMinus);
        add(speedPlus);
        add(speedMinus);
        add(saveBtn);
        add(finishBtn);

        #if !mobile
        var resetBtn = new FlxButton(20, 500, "Reset First Boot", function()
        {
            #if sys
            var bootPath:String = "assets/data/firstboot.txt";
            if (FileSystem.exists(bootPath))
                FileSystem.deleteFile(bootPath);
            #end
        });

        scaleButton(resetBtn, buttonScale);
        add(resetBtn);
        #end
    }

    function scaleButton(button:FlxButton, scale:Float):Void
    {
        button.scale.set(scale, scale);
        button.updateHitbox();
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
                    if (!FileSystem.exists("assets/crash"))
                        FileSystem.createDirectory("assets/crash");

                    var crashLog:String =
                        "Crash Report\n" +
                        "====================\n" +
                        "Error: " + errorMsg + "\n" +
                        "State: ConfigState\n";

                    File.saveContent(
                        "assets/crash/crash_" + Date.now().getTime() + ".txt",
                        crashLog
                    );
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

        #if mobile
        FlxG.save.data.waveAmplitude = waveAmplitude;
        FlxG.save.data.frequency = frequency;
        FlxG.save.data.speed = speed;
        FlxG.save.data.uiVisible = uiVisible;
        FlxG.save.flush();

        #elseif sys
        File.saveContent("assets/data/settings.txt", content);
        #end
    }

    function completeSetup():Void
    {
        saveSettings();

        #if mobile
        FlxG.save.data.configured = true;
        FlxG.save.flush();

        #elseif sys
        File.saveContent("assets/data/firstboot.txt", "configured=true");
        #end

        FlxG.switchState(new PlayState());
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (shader != null)
            shader.uTime.value[0] += elapsed;
    }
}
