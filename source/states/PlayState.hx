package states;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUISlider;
import openfl.display.Shader;
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

    override public function create():Void
    {
        super.create();

        // =========================
        // Background padrão
        // =========================
        bg = new FlxSprite();
        bg.loadGraphic("assets/images/bg/default.png");
        bg.screenCenter();
        add(bg);

        // =========================
        // Shader
        // =========================
        shader = new CustomWaveShader();

        shader.uTime.value = [0.0];
        shader.uSpeed.value = [2.0];
        shader.uFrequency.value = [10.0];
        shader.uWaveAmplitude.value = [0.02];
        shader.effectType.value = [0]; // FLAG

        bg.shader = shader;

        // =========================
        // Botão carregar imagem
        // =========================
        var loadButton = new FlxUIButton(20, 20, "Adicionar Imagem", loadImage);
        add(loadButton);

        // =========================
        // Wave Amplitude
        // =========================
        ampText = new FlxText(20, 70, 300, "Wave Amplitude: 0.02");
        add(ampText);

        var ampSlider = new FlxUISlider(this, "setAmplitude", 20, 90, 0.0, 0.2, 250, 20);
        ampSlider.value = 0.02;
        add(ampSlider);

        // =========================
        // Frequency
        // =========================
        freqText = new FlxText(20, 130, 300, "Frequency: 10");
        add(freqText);

        var freqSlider = new FlxUISlider(this, "setFrequency", 20, 150, 1.0, 50.0, 250, 20);
        freqSlider.value = 10;
        add(freqSlider);

        // =========================
        // Speed
        // =========================
        speedText = new FlxText(20, 190, 300, "Speed: 2");
        add(speedText);

        var speedSlider = new FlxUISlider(this, "setSpeed", 20, 210, 0.1, 10.0, 250, 20);
        speedSlider.value = 2;
        add(speedSlider);

        // =========================
        // uTime display
        // =========================
        timeText = new FlxText(20, 250, 300, "uTime: 0");
        add(timeText);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        // =========================
        // Atualização contínua do shader
        // =========================
        shader.uTime.value[0] += elapsed;

        // Evita overflow
        if (shader.uTime.value[0] > 999999)
            shader.uTime.value[0] = 0;

        // Atualiza texto visual
        timeText.text = "uTime: " + Std.string(Std.int(shader.uTime.value[0] * 100) / 100);
    }

    // =========================
    // Slider Functions
    // =========================
    public function setAmplitude(value:Float):Void
    {
        shader.uWaveAmplitude.value = [value];
        ampText.text = "Wave Amplitude: " + Std.string(value);
    }

    public function setFrequency(value:Float):Void
    {
        shader.uFrequency.value = [value];
        freqText.text = "Frequency: " + Std.string(value);
    }

    public function setSpeed(value:Float):Void
    {
        shader.uSpeed.value = [value];
        speedText.text = "Speed: " + Std.string(value);
    }

    // =========================
    // Carregar imagem
    // =========================
    function loadImage():Void
    {
        fileRef = new FileReference();
        fileRef.addEventListener(Event.SELECT, onFileSelected);
        fileRef.browse([
            new FileFilter("Imagens", "*.png;*.jpg;*.jpeg")
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
            bg.screenCenter();
            bg.shader = shader;
        });

        loader.loadBytes(fileRef.data);
    }
}

// =========================
// Shader Class
// =========================
class CustomWaveShader extends Shader
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
            gl_FragColor = texture2D(bitmap, uv);
        }
    ')
    public function new()
    {
        super();
    }
}
