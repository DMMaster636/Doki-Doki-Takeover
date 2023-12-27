package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.Assets;
import shaders.ColorMaskShader;

using StringTools;

class WarningState extends MusicBeatState
{
	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var warning:FlxSprite;

	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		persistentUpdate = true;

		startIntro();

		super.create();
	}

	function startIntro()
	{
		if (!initialized)
		{
			FlxG.sound.playMusic(Paths.music('ghost'), 0);
			Conductor.changeBPM(120);
			FlxG.sound.music.fadeIn(2, 0, 0.7);
		}

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(blackScreen);

		warning = new FlxSprite(0, 0).loadGraphic(Paths.image('DDLCIntroWarning'));
		warning.screenCenter();
		warning.antialiasing = SaveData.globalAntialiasing;
		add(warning);

		initialized = true;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		var pressedEnter:Bool = controls.ACCEPT || FlxG.mouse.justPressed;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		if (pressedEnter && !transitioning)
		{
			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;

			SaveData.warningBadEnding = true;
			SaveData.save();

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				MusicBeatState.switchState(new EvilTitleState());
			});
		}

		super.update(elapsed);
	}
}
