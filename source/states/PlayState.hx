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
import openfl.net.FileFilter;
import openfl.display.Loader;
import openfl.display.Bitmap;
import openfl.net.URLRequest;
import openfl.Lib;
import openfl.media.Sound;

import lime.app.Application;
import lime.ui.Window;

import haxe.Http;

import states.CustomWaveShader;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

class PlayState extends FlxState
{
    var bg:FlxSprite;
    var shader:CustomWaveShader;
    var fileRef:FileReference;

    var ampText:FlxText;
    var freqText:FlxText;
    var speedText:FlxText;
    var timeText:FlxText;
    var versionText:FlxText;
    var updatePrompt:FlxText;

    var waveAmplitude:Float = 0.1;
    var frequency:Float = 5.0;
    var speed:Float = 2.0;
    var brightness:Float = 1.0;

    var brightnessOverlay:FlxSprite;

    var uiVisible:Bool = true;
    var uiElements:Array<Dynamic> = [];

    var defaultImage:String = "assets/images/bg/cheeseburger.png";

    var currentVersion:String = "0.0.5";
    var latestVersion:String = "";
    var updateAvailable:Bool = false;

    override public function create():Void
    {
        super.create();

        loadSettings();

        bg = new FlxSprite();
        bg.loadGraphic(defaultImage);
        fitImageToScreen();
        add(bg);

        shader = new CustomWaveShader();

        shader.uTime.value = [0.0];
        shader.uSpeed.value = [speed];
        shader.uFrequency.value = [frequency];
        shader.uWaveAmplitude.value = [waveAmplitude];

        bg.shader = shader;

        brightnessOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        brightnessOverlay.scrollFactor.set();
        add(brightnessOverlay);

        checkForUpdates();

        versionText = new FlxText(10, FlxG.height - 50, 500, "Version: " + currentVersion);
        add(versionText);
        uiElements.push(versionText);

        updatePrompt = new FlxText(FlxG.width / 2 - 300, FlxG.height / 2 - 40, 600, "");
        updatePrompt.visible = false;
        add(updatePrompt);

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

        var brightMinus = new FlxButton(20, 300, "-", function()
        {
            brightness = Math.max(0, brightness - 0.1);
            updateBrightness();
        });
        add(brightMinus);
        uiElements.push(brightMinus);

        var brightPlus = new FlxButton(120, 300, "+", function()
        {
            brightness = Math.min(1, brightness + 0.1);
            updateBrightness();
        });
        add(brightPlus);
        uiElements.push(brightPlus);

        timeText = new FlxText(20, 330, 400, "Time: 0");
        add(timeText);

        var toggleText = new FlxText(20, FlxG.height - 30, 500, "Press SPACE to toggle UI");
        add(toggleText);

        updateBrightness();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        shader.uTime.value[0] += elapsed;

        timeText.text = "Time: " + Std.string(Std.int(shader.uTime.value[0] * 100) / 100);

        if (FlxG.keys.justPressed.SPACE)
        {
            uiVisible = !uiVisible;

            for (e in uiElements)
            {
                e.visible = uiVisible;
                e.active = uiVisible;
            }
        }
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
            }
