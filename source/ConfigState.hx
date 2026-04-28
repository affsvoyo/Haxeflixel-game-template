package states;

import flixel.FlxState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import states.PlayState;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

class ConfigState extends FlxState
{
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

        var title = new FlxText(20, 20, 600, "Shader Default Settings");
        title.size = 24;
        add(title);

        ampText = new FlxText(20, 60, 400, "Wave Amplitude: " + waveAmplitude);
        add(ampText);

        add(new FlxButton(20, 90, "Amplitude +", function()
        {
            waveAmplitude += 0.01;
            updateTexts();
        }));

        add(new FlxButton(140, 90, "Amplitude -", function()
        {
            waveAmplitude = Math.max(0, waveAmplitude - 0.01);
            updateTexts();
        }));

        freqText = new FlxText(20, 130, 400, "Frequency: " + frequency);
        add(freqText);

        add(new FlxButton(20, 160, "Frequency +", function()
        {
            frequency += 1;
            updateTexts();
        }));

        add(new FlxButton(140, 160, "Frequency -", function()
        {
            frequency = Math.max(1, frequency - 1);
            updateTexts();
        }));

        speedText = new FlxText(20, 200, 400, "Speed: " + speed);
        add(speedText);

        add(new FlxButton(20, 230, "Speed +", function()
        {
            speed += 0.1;
            updateTexts();
        }));

        add(new FlxButton(140, 230, "Speed -", function()
        {
            speed = Math.max(0.1, speed - 0.1);
            updateTexts();
        }));

        add(new FlxButton(20, 320, "Save Settings", saveSettings));
        add(new FlxButton(180, 320, "Finish Setup", completeSetup));

        add(new FlxButton(20, 370, "Reset First Boot", function()
        {
            var bootPath:String = "assets/data/firstboot.txt";

            #if sys
            if (FileSystem.exists(bootPath))
                FileSystem.deleteFile(bootPath);
            #end
        }));
    }

    function updateTexts():Void
    {
        ampText.text = "Wave Amplitude: " + waveAmplitude;
        freqText.text = "Frequency: " + frequency;
        speedText.text = "Speed: " + speed;
    }

    function saveSettings():Void
    {
        var content =
            "waveAmplitude=" + waveAmplitude + "\n" +
            "frequency=" + frequency + "\n" +
            "speed=" + speed + "\n" +
            "defaultImage=assets/images/bg/default.png\n" +
            "uiVisible=" + uiVisible;

        #if sys
        File.saveContent("assets/data/settings.txt", content);
        #end
    }

    function completeSetup():Void
    {
        saveSettings();

        #if sys
        File.saveContent("assets/data/firstboot.txt", "configured=true");
        #end

        FlxG.switchState(new PlayState());
    }
}
