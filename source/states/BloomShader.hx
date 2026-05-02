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

class BloomState extends FlxState
{
	var bg:FlxSprite;
	var shader:BloomShader;
	var fileRef:FileReference;

	var uiVisible:Bool = true;
	var uiElements:Array<Dynamic> = [];

	// 🔥 Bloom controls
	var intensity:Float = 1.0;
	var blurSize:Float = 0.002;

	var brightnessOverlay:FlxSprite;

	var versionText:FlxText;
	var intensityText:FlxText;
	var blurText:FlxText;

	var defaultImage:String = "assets/images/bg/cheeseburger.png";
	var currentVersion:String = "0.0.8";

	override public function create():Void
	{
		super.create();

		initCrashHandler();

		// =========================
		// BACKGROUND
		// =========================
		bg = new FlxSprite();
		bg.loadGraphic(defaultImage);
		fitImageToScreen();
		add(bg);

		// =========================
		// SHADER
		// =========================
		shader = new BloomShader();
		shader.intensity.value = [intensity];
		shader.blurSize.value = [blurSize];

		bg.shader = shader;

		// =========================
		// DARK OVERLAY (fake brightness control)
		// =========================
		brightnessOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		brightnessOverlay.scrollFactor.set();
		add(brightnessOverlay);

		// =========================
		// VERSION TEXT
		// =========================
		versionText = new FlxText(10, FlxG.height - 30, 400, "Version: " + currentVersion);
		add(versionText);
		uiElements.push(versionText);

		// =========================
		// CONTROLS TEXT
		// =========================
		intensityText = new FlxText(10, 60, 400, "Intensity: " + intensity);
		add(intensityText);
		uiElements.push(intensityText);

		blurText = new FlxText(10, 100, 400, "Blur Size: " + blurSize);
		add(blurText);
		uiElements.push(blurText);

		// =========================
		// BUTTONS
		// =========================

		var addImg = new FlxButton(10, 10, "Add Image", function()
		{
			loadImage();
		});
		add(addImg);
		uiElements.push(addImg);

		var resetBtn = new FlxButton(120, 10, "Reset", function()
		{
			resetValues();
		});
		add(resetBtn);
		uiElements.push(resetBtn);

		var exitBtn = new FlxButton(230, 10, "Exit", function()
		{
			closeGame();
		});
		add(exitBtn);
		uiElements.push(exitBtn);

		// =========================
		// INTENSITY CONTROLS
		// =========================

		var minusInt = new FlxButton(10, 140, "-", function()
		{
			intensity = Math.max(0, intensity - 0.1);
			updateShader();
		});
		add(minusInt);
		uiElements.push(minusInt);

		var plusInt = new FlxButton(70, 140, "+", function()
		{
			intensity += 0.1;
			updateShader();
		});
		add(plusInt);
		uiElements.push(plusInt);

		// =========================
		// BLUR CONTROLS
		// =========================

		var minusBlur = new FlxButton(10, 180, "-", function()
		{
			blurSize = Math.max(0.0005, blurSize - 0.0005);
			updateShader();
		});
		add(minusBlur);
		uiElements.push(minusBlur);

		var plusBlur = new FlxButton(70, 180, "+", function()
		{
			blurSize += 0.0005;
			updateShader();
		});
		add(plusBlur);
		uiElements.push(plusBlur);

		updateShader();
	}

	// =========================
	// UPDATE SHADER
	// =========================

	function updateShader():Void
	{
		shader.intensity.value = [intensity];
		shader.blurSize.value = [blurSize];

		intensityText.text = "Intensity: " + intensity;
		blurText.text = "Blur Size: " + blurSize;
	}

	// =========================
	// RESET
	// =========================

	function resetValues():Void
	{
		intensity = 1.0;
		blurSize = 0.002;
		updateShader();
	}

	// =========================
	// UPDATE LOOP
	// =========================

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

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

	// =========================
	// IMAGE FIT
	// =========================

	function fitImageToScreen():Void
	{
		if (bg == null) return;

		var sx = FlxG.width / bg.width;
		var sy = FlxG.height / bg.height;
		var scale = Math.max(sx, sy);

		bg.scale.set(scale, scale);
		bg.updateHitbox();
		bg.screenCenter();
	}

	// =========================
	// LOAD IMAGE
	// =========================

	function loadImage():Void
	{
		fileRef = new FileReference();
		fileRef.addEventListener(Event.SELECT, onSelect);
		fileRef.browse([new FileFilter("Images", "*.png;*.jpg;*.jpeg")]);
	}

	function onSelect(e:Event):Void
	{
		fileRef.addEventListener(Event.COMPLETE, onLoad);
		fileRef.load();
	}

	function onLoad(e:Event):Void
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

	// =========================
	// EXIT EFFECT
	// =========================

	function closeGame():Void
	{
		FlxG.switchState(new PlayState());
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
				var err = e.error != null ? Std.string(e.error) : "Unknown error";
				FlxG.log.error("CRASH: " + err);
			}
		);
	}
}
