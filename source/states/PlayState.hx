package states;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.UncaughtErrorEvent;
import openfl.net.FileFilter;
import openfl.display.Loader;
import openfl.display.Bitmap;
import openfl.Lib;

import lime.app.Application;
import lime.ui.Window;

import shader.Shaders;

#if sys
import sys.io.File;
import sys.FileSystem;
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
    var currentVersion:String = "0.0.7";

    override public function create():Void
    {
        super.create();

        #if mobile
        FlxG.resizeGame(1280, 720);
        #end

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

        createUI();
        updateBrightness();
    }

    function createUI():Void
    {
        var buttonScale:Float = #if mobile 1.5 #else 1.0 #end;

        versionText = new FlxText(20, FlxG.height - 50, 500, "Version: " + currentVersion);
        addUI(versionText);

        #if !mobile
        var loadBtn = new FlxButton(20, 20, "Add Image", function()
        {
            playClick();
            loadImage();
        });
        scaleButton(loadBtn, buttonScale);
        addUI(loadBtn);
        #end

        var exitBtn = new FlxButton(FlxG.width - 120, 20, "Exit", function()
        {
            playClick();
            closeGame();
        });
        scaleButton(exitBtn, buttonScale);
        addUI(exitBtn);

        var resetBtn = new FlxButton(20, FlxG.height - 80, "Reset", function()
        {
            playClick();
            resetDefaults();
        });
        scaleButton(resetBtn, buttonScale);
        addUI(resetBtn);

        ampText = new FlxText(20, 70, 400, "");
        freqText = new FlxText(20, 140, 400, "");
        speedText = new FlxText(20, 210, 400, "");
        timeText = new FlxText(20, 330, 400, "Time: 0");

        addUI(ampText);
        addUI(freqText);
        addUI(speedText);
        addUI(timeText);

        createControlButtons(buttonScale);

        #if !mobile
        var toggleText = new FlxText(20, FlxG.height - 30, 500, "Press SPACE to toggle UI");
        addUI(toggleText);
        #end

        updateShaderValues();
    }

    function createControlButtons(scale:Float):Void
    {
        createPair(20, 95, function() {
            waveAmplitude = Math.max(0, waveAmplitude - 0.005);
            updateShaderValues();
        }, function() {
            waveAmplitude += 0.005;
            updateShaderValues();
        }, scale);

        createPair(20, 165, function() {
            frequency = Math.max(1, frequency - 1);
            updateShaderValues();
        }, function() {
            frequency += 1;
            updateShaderValues();
        }, scale);

        createPair(20, 235, function() {
            speed = Math.max(0.1, speed - 0.1);
            updateShaderValues();
        }, function() {
            speed += 0.1;
            updateShaderValues();
        }, scale);

        createPair(20, 300, function() {
            brightness = Math.max(0, brightness - 0.1);
            updateBrightness();
        }, function() {
            brightness = Math.min(1, brightness + 0.1);
            updateBrightness();
        }, scale);
    }

    function createPair(x:Float, y:Float, minusFunc:Void->Void, plusFunc:Void->Void, scale:Float):Void
    {
        var minus = new FlxButton(x, y, "-", minusFunc);
        var plus = new FlxButton(x + 100, y, "+", plusFunc);

        scaleButton(minus, scale);
        scaleButton(plus, scale);

        addUI(minus);
        addUI(plus);
    }

    function addUI(obj:Dynamic):Void
    {
        add(obj);
        uiElements.push(obj);
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

        #if !mobile
        if (FlxG.keys.justPressed.SPACE)
        {
            uiVisible = !uiVisible;

            for (e in uiElements)
            {
                e.visible = uiVisible;
                e.active = uiVisible;
            }
        }
        #end
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

        saveSettings();
    }

    function playClick():Void
    {
        FlxG.sound.play("assets/sounds/click.ogg");
    }

    function closeGame():Void
    function closeGame():Void
{
#if mobile
#if sys
            Sys.exit(0);
            #end
        #end
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
            #end
        }
    });
    #end
}
    function loadSettings():Void
    {
        #if mobile
        if (FlxG.save.data.waveAmplitude != null)
            waveAmplitude = FlxG.save.data.waveAmplitude;

        if (FlxG.save.data.frequency != null)
            frequency = FlxG.save.data.frequency;

        if (FlxG.save.data.speed != null)
            speed = FlxG.save.data.speed;

        #elseif sys
        var path = "assets/data/settings.txt";

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

    function saveSettings():Void
    {
        #if mobile
        FlxG.save.data.waveAmplitude = waveAmplitude;
        FlxG.save.data.frequency = frequency;
        FlxG.save.data.speed = speed;
        FlxG.save.flush();
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

    #if !mobile
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
    #end
            }
