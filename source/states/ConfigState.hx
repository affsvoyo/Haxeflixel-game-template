package states;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.group.FlxGroup;
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

    // POPUP
    var popupBg:FlxSprite;
    var popupBox:FlxSprite;
    var popupText:FlxText;
    var popupBtn:FlxButton;

    override public function create():Void
    {
        super.create();

        createReadme();

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

        // POPUP BETA
        createBetaPopup();
    }

    // =========================
    // POPUP
    // =========================

    function createBetaPopup():Void
    {
        popupBg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xAA000000);
        popupBg.scrollFactor.set(0, 0);
        add(popupBg);

        popupBox = new FlxSprite().makeGraphic(520, 260, 0xFF1A1A1A);
        popupBox.screenCenter();
        popupBox.scrollFactor.set(0, 0);
        add(popupBox);

        popupText = new FlxText(0, 0, 500,
            "BETA VERSION\n\n" +
            "This game is currently in BETA.\n" +
            "You may encounter bugs, glitches\n" +
            "or unfinished features.\n\n" +
            "Enjoy and report issues if you find any!",
            18
        );
        popupText.alignment = "center";
        popupText.screenCenter();
        popupText.y -= 40;
        add(popupText);

        popupBtn = new FlxButton(0, 0, "OK", function()
        {
            removePopup();
        });

        popupBtn.screenCenter();
        popupBtn.y += 90;
        add(popupBtn);
    }

    function removePopup():Void
    {
        remove(popupBg);
        remove(popupBox);
        remove(popupText);
        remove(popupBtn);
    }

    // =========================
    // BUTTONS
    // =========================

    function createButtons():Void
    {
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
    }

    function scaleButton(button:FlxButton, scale:Float):Void
    {
        button.scale.set(scale, scale);
        button.updateHitbox();
    }

    // =========================
    // CRASH HANDLER
    // =========================

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
                        "Crash Report\n====================\n" +
                        "Error: " + errorMsg + "\n" +
                        "State: ConfigState\n";

                    File.saveContent(
                        "assets/crash/crash_" + Date.now().getTime() + ".txt",
                        crashLog
                    );
                }
                catch (saveError:Dynamic) {}
                #end
            }
        );
    }

    // =========================
    // UI UPDATE
    // =========================

    function updateTexts():Void
    {
        ampText.text = "Wave Amplitude: " + waveAmplitude;
        freqText.text = "Frequency: " + frequency;
        speedText.text = "Speed: " + speed;

        shader.uWaveAmplitude.value = [waveAmplitude];
        shader.uFrequency.value = [frequency];
        shader.uSpeed.value = [speed];
    }

    // =========================
    // SAVE
    // =========================

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

    // =========================
    // README
    // =========================

    function createReadme():Void
    {
        #if sys
        var readmePath:String = "do NOT readme.txt";

        if (!FileSystem.exists(readmePath))
        {
            var readmeContent:String = "STRIDENT CRISIS SHADER GENERATOR...\n(omitted for brevity)";
            File.saveContent(readmePath, readmeContent);
        }
        #end
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (shader != null)
            shader.uTime.value[0] += elapsed;
    }
}
