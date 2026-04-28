package states;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

import openfl.net.FileReference;
import openfl.events.Event;
import openfl.net.FileFilter;
import openfl.display.Loader;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.net.URLRequest;
import openfl.net.navigateToURL;

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

    var uiVisible:Bool = true;
    var uiElements:Array<Dynamic> = [];

    var defaultImage:String = "assets/images/bg/cheeseburger.png";

    var currentVersion:String = "1.0.0";
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

        checkForUpdates();

        versionText = new FlxText(10, FlxG.height - 50, 500, "Version: " + currentVersion);
        versionText.setFormat(null, 16, 0xFFFFFFFF, LEFT);
        add(versionText);

        updatePrompt = new FlxText(
            FlxG.width / 2 - 300,
            FlxG.height / 2 - 40,
            600,
            ""
        );
        updatePrompt.setFormat(null, 20, 0xFFFFFFFF, CENTER);
        updatePrompt.visible = false;
        add(updatePrompt);

        var loadBtn = new FlxButton(20, 20, "Add Image", loadImage);
        add(loadBtn);
        uiElements.push(loadBtn);

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

        timeText = new FlxText(20, 280, 400, "uTime: 0");
        add(timeText);
        uiElements.push(timeText);

        var toggleText = new FlxText(
            20,
            FlxG.height - 30,
            500,
            "Press SPACE to hide/show UI"
        );
        toggleText.setFormat(null, 16, 0xFFFFFFFF, LEFT);
        add(toggleText);
        uiElements.push(toggleText);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        shader.uTime.value[0] += elapsed;

        if (shader.uTime.value[0] > 999999)
            shader.uTime.value[0] = 0;

        timeText.text = "uTime: " + Std.string(
            Std.int(shader.uTime.value[0] * 100) / 100
        );

        if (FlxG.keys.justPressed.SPACE)
        {
            uiVisible = !uiVisible;

            for (element in uiElements)
            {
                element.visible = uiVisible;
                element.active = uiVisible;
            }
        }

        if (updateAvailable)
        {
            if (FlxG.keys.justPressed.ENTER)
            {
                navigateToURL(
                    new URLRequest(
                        "https://github.com/affsvoyo/Strident-Crisis-Shader-Generator/releases/latest"
                    ),
                    "_blank"
                );

                updatePrompt.visible = false;
                updateAvailable = false;
            }

            if (FlxG.keys.justPressed.ESCAPE)
            {
                updatePrompt.visible = false;
                updateAvailable = false;
            }
        }
    }

    function checkForUpdates():Void
    {
        var versionURL = "https://raw.githubusercontent.com/affsvoyo/Strident-Crisis-Shader-Generator/main/Version.md";

        var http = new Http(versionURL);

        http.onData = function(data:String)
        {
            latestVersion = StringTools.trim(data);

            if (latestVersion != currentVersion)
            {
                updateAvailable = true;

                updatePrompt.text =
                    "New Version Available: " + latestVersion +
                    "\nPress ENTER to download update" +
                    "\nPress ESC to ignore";

                updatePrompt.visible = true;
            }
        };

        http.onError = function(error:String)
        {
            trace("Version check failed: " + error);
        };

        http.request();
    }

    function loadSettings():Void
    {
        var path = "assets/data/settings.txt";

        #if sys
        if (!FileSystem.exists(path))
            return;

        var lines:Array<String> = File.getContent(path).split("\n");

        for (line in lines)
        {
            var parts = line.split("=");

            if (parts.length < 2)
                continue;

            switch(parts[0])
            {
                case "waveAmplitude":
                    waveAmplitude = Std.parseFloat(parts[1]);

                case "frequency":
                    frequency = Std.parseFloat(parts[1]);

                case "speed":
                    speed = Std.parseFloat(parts[1]);
            }
        }
        #end
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

    function fitImageToScreen():Void
    {
        if (bg == null || bg.graphic == null)
            return;

        bg.scale.set(1, 1);
        bg.updateHitbox();

        var scaleX:Float = FlxG.width / bg.width;
        var scaleY:Float = FlxG.height / bg.height;

        var finalScale:Float = Math.max(scaleX, scaleY);

        bg.scale.set(finalScale, finalScale);
        bg.updateHitbox();
        bg.screenCenter();
    }

    function loadImage():Void
    {
        fileRef = new FileReference();

        fileRef.addEventListener(Event.SELECT, onFileSelected);

        fileRef.browse([
            new FileFilter("Images", "*.png;*.jpg;*.jpeg")
        ]);
    }

    function onFileSelected(e:Event):Void
    {
        fileRef.addEventListener(Event.COMPLETE, onFileLoaded);
        fileRef.load();
    }

    function onFileLoaded(e:Event):Void
    {
        var loader = new Loader();

        loader.contentLoaderInfo.addEventListener(
            Event.COMPLETE,
            function(_)
            {
                var bmp:Bitmap = cast loader.content;

                bg.loadGraphic(bmp.bitmapData);

                fitImageToScreen();
                bg.shader = shader;
            }
        );

        loader.loadBytes(fileRef.data);
    }
            }
