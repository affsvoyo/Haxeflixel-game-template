package states;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.system.FlxAssets.FlxShader;

import openfl.net.FileReference;
import openfl.events.Event;
import openfl.net.FileFilter;
import openfl.display.Loader;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

class PlayState extends FlxState
{
    var bg:FlxSprite;
    var shader:CustomWaveShader;
    var fileRef:FileReference;

    var ampText:FlxText;
    var freqText:FlxText;
    var speedText:FlxText;
    var timeText:FlxText;

    var waveAmplitude:Float = 0.1;
    var frequency:Float = 5.0;
    var speed:Float = 2.0;

    var uiVisible:Bool = true;
    var uiElements:Array<Dynamic> = [];

    override public function create():Void
    {
        super.create();

        bg = new FlxSprite();
        bg.loadGraphic("assets/images/bg/cheeseburger.png");
        fitImageToScreen();
        add(bg);

        shader = new CustomWaveShader();
        shader.uTime.value = [0.0];
        shader.uSpeed.value = [speed];
        shader.uFrequency.value = [frequency];
        shader.uWaveAmplitude.value = [waveAmplitude];
        shader.effectType.value = [0];

        bg.shader = shader;

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

        var ampPlus = new FlxButton(60, 95, "+", function()
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

        var freqPlus = new FlxButton(60, 165, "+", function()
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

        var speedPlus = new FlxButton(60, 235, "+", function()
        {
            speed += 0.1;
            updateShaderValues();
        });
        add(speedPlus);
        uiElements.push(speedPlus);

        timeText = new FlxText(20, 280, 400, "uTime: 0");
        add(timeText);
        uiElements.push(timeText);

        var toggleText:FlxText = new FlxText(20, FlxG.height - 30, 500, "Press SPACE to hide/show UI");
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

        timeText.text = "uTime: " + Std.string(Std.int(shader.uTime.value[0] * 100) / 100);

        if (FlxG.keys.justPressed.SPACE)
        {
            uiVisible = !uiVisible;

            for (element in uiElements)
            {
                element.visible = uiVisible;
                element.active = uiVisible;
            }
        }
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
        if (bg == null || bg.graphic == null) return;

        bg.scale.set(1, 1);
        bg.updateHitbox();

        var screenW:Float = FlxG.width;
        var screenH:Float = FlxG.height;

        var imageW:Float = bg.width;
        var imageH:Float = bg.height;

        var scaleX:Float = screenW / imageW;
        var scaleY:Float = screenH / imageH;

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

        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(_)
        {
            var bmp:Bitmap = cast loader.content;
            var bmpData:BitmapData = bmp.bitmapData;

            bg.loadGraphic(bmpData);
            fitImageToScreen();
            bg.shader = shader;
        });

        loader.loadBytes(fileRef.data);
    }
}

class CustomWaveShader extends FlxShader
{
    @:glFragmentSource('
        #pragma header

        uniform float uTime;

        const int EFFECT_TYPE_DREAMY = 1;
        const int EFFECT_TYPE_WAVY = 2;
        const int EFFECT_TYPE_HEAT_WAVE_HORIZONTAL = 3;
        const int EFFECT_TYPE_HEAT_WAVE_VERTICAL = 4;
        const int EFFECT_TYPE_FLAG = 0;

        uniform int effectType;
        uniform float uSpeed;
        uniform float uFrequency;
        uniform float uWaveAmplitude;

        vec2 sineWave(vec2 pt)
        {
            float x = 0.0;
            float y = 0.0;

            if (effectType == EFFECT_TYPE_DREAMY)
            {
                float offsetX = sin(pt.y * uFrequency + uTime * uSpeed) * uWaveAmplitude;
                pt.x += offsetX;
            }
            else if (effectType == EFFECT_TYPE_WAVY)
            {
                float offsetY = sin(pt.x * uFrequency + uTime * uSpeed) * uWaveAmplitude;
                pt.y += offsetY;
            }
            else if (effectType == EFFECT_TYPE_HEAT_WAVE_HORIZONTAL)
            {
                x = sin(pt.x * uFrequency + uTime * uSpeed) * uWaveAmplitude;
            }
            else if (effectType == EFFECT_TYPE_HEAT_WAVE_VERTICAL)
            {
                y = sin(pt.y * uFrequency + uTime * uSpeed) * uWaveAmplitude;
            }
            else if (effectType == EFFECT_TYPE_FLAG)
            {
                y = sin(pt.y * uFrequency + 10.0 * pt.x + uTime * uSpeed) * uWaveAmplitude;
                x = sin(pt.x * uFrequency + 5.0 * pt.y + uTime * uSpeed) * uWaveAmplitude;
            }

            return vec2(pt.x + x, pt.y + y);
        }

        void main()
        {
            vec2 uv = sineWave(openfl_TextureCoordv);
            gl_FragColor = flixel_texture2D(bitmap, uv);
        }
    ')

    public function new()
    {
        super();
    }
}
