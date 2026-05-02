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
createReadme();
        #if sys
            var crashLog:String =
                        "Crash Report\n" +
                        "====================\n" +
                        "Error: " + errorMsg + "\n" +
                        "State: ConfigState\n";

                    File.saveContent(
                        "assets/crash/crash_" + Date.now().getTime() + ".txt",
                        crashLog
                    );
        #end
        
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

    function createReadme():Void
{
    #if sys
    var readmePath:String = "assets/DO NOT readme.txt";

    if (!FileSystem.exists(readmePath))
    {
        var readmeContent:String =
" ███████╗████████╗██████╗ ██╗██████╗ ███████╗███╗   ██╗████████╗\n" +
" ██╔════╝╚══██╔══╝██╔══██╗██║██╔══██╗██╔════╝████╗  ██║╚══██╔══╝\n" +
" ███████╗   ██║   ██████╔╝██║██║  ██║█████╗  ██╔██╗ ██║   ██║   \n" +
" ╚════██║   ██║   ██╔══██╗██║██║  ██║██╔══╝  ██║╚██╗██║   ██║   \n" +
" ███████║   ██║   ██║  ██║██║██████╔╝███████╗██║ ╚████║   ██║   \n" +
" ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝   \n\n" +

"STRIDENT CRISIS SHADER GENERATOR\n" +
"========================================\n\n" +

"HEY!\n" +
"Thanks for downloading Strident Crisis Shader Generator!\n\n" +

"This project is a visual rendering and shader development framework.\n" +
"It allows advanced shader generation, glitch systems, wave distortions,\n" +
"CRT simulation, corruption effects, and full visual experimentation.\n\n" +

"##################################################################################\n" +
"PERMISSIONS\n" +
"##################################################################################\n\n" +

"You have FULL PERMISSION to:\n" +
"- Modify\n" +
"- Fork\n" +
"- Expand\n" +
"- Stream\n" +
"- Upload\n" +
"- Showcase\n" +
"- Monetize original creations\n" +
"- Build your own systems\n\n" +

"##################################################################################\n" +
"CORE FEATURES\n" +
"##################################################################################\n\n" +

"- Real-time shader editing\n" +
"- Wave systems\n" +
"- Glitch effects\n" +
"- RGB split\n" +
"- CRT filters\n" +
"- Bloom layers\n" +
"- Visual corruption systems\n" +
"- HaxeFlixel integration\n" +
"- Mobile/Desktop support\n" +
"- Export systems\n\n" +

"##################################################################################\n" +
"CONFIG SYSTEM\n" +
"##################################################################################\n\n" +

"This setup menu allows:\n" +
"- Default shader configuration\n" +
"- Amplitude tuning\n" +
"- Frequency tuning\n" +
"- Speed tuning\n" +
"- First boot initialization\n" +
"- Crash logging\n" +
"- Save management\n\n" +

"##################################################################################\n" +
"WARNING\n" +
"##################################################################################\n\n" +

"Heavy shader combinations may:\n" +
"- Reduce FPS\n" +
"- Increase compile times\n" +
"- Cause mobile lag\n" +
"- Stress GPUs\n\n" +

"Optimize before release.\n\n" +

"##################################################################################\n" +
"FINAL WORDS\n" +
"##################################################################################\n\n" +

"Build impossible visuals.\n" +
"Push HaxeFlixel beyond normal limits.\n" +
"Create chaos.\n" +
"Create style.\n" +
"Create STRIDENT CRISIS.\n\n" +

"System Status:\n" +
"[VISUAL CORE ACTIVE]\n" +
"[SHADER ENGINE READY]\n" +
"[GENERATOR ONLINE]\n";

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
