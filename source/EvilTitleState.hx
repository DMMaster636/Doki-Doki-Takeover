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

class EvilTitleState extends MusicBeatState
{
	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;

	var tbdSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		persistentUpdate = true;

		curWacky = FlxG.random.getObject(getIntroTextShit());

		#if sys
		if (!initialized && Argument.parse(Sys.args()))
		{
			initialized = true;
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			Conductor.changeBPM(82.5);
			return;
		}
		#end

		startIntro();

		super.create();
	}

	var logoBl:FlxSprite;
	var backdrop:FlxBackdrop;
	var titleText:FlxSprite;
	var vignette:FlxSprite;

	function startIntro()
	{
		if (!initialized)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			Conductor.changeBPM(82.5);
			FlxG.sound.music.fadeIn(2, 0, 0.7);
		}

		backdrop = new FlxBackdrop(Paths.image('scrolling_BG'));
		backdrop.velocity.set(-40, -40);
		backdrop.antialiasing = SaveData.globalAntialiasing;
		add(backdrop);

		var creditsBG:FlxBackdrop = new FlxBackdrop(Paths.image('pocBackground'));
		creditsBG.velocity.set(-50, 0);
		creditsBG.antialiasing = SaveData.globalAntialiasing;
		add(creditsBG);

		var scanline:FlxBackdrop = new FlxBackdrop(Paths.image('scanlines'));
		scanline.velocity.set(0, 20);
		scanline.antialiasing = SaveData.globalAntialiasing;
		add(scanline);

		var gradient:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gradent'));
		gradient.antialiasing = SaveData.globalAntialiasing;
		gradient.scrollFactor.set(0.1, 0.1);
		gradient.screenCenter();
		gradient.setGraphicSize(Std.int(gradient.width * 1.4));
		add(gradient);

		logoBl = new FlxSprite(320, 0);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = SaveData.globalAntialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, true);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		add(logoBl);

		titleText = new FlxSprite(200, 576);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = SaveData.globalAntialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		vignette = new FlxSprite(0, 0).loadGraphic(Paths.image('menuvignette'));
		vignette.alpha = 0.8;
		add(vignette);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		credTextShit.visible = false;

		tbdSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('TBDLogoBW'));
		add(tbdSpr);
		tbdSpr.visible = false;
		tbdSpr.setGraphicSize(Std.int(tbdSpr.width * 0.8));
		tbdSpr.updateHitbox();
		tbdSpr.screenCenter(X);
		tbdSpr.antialiasing = true;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('data/introTextEvil'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
			swagGoodArray.push(i.split('--'));

		return swagGoodArray;
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

		if (pressedEnter && !transitioning && skippedIntro)
		{
			if (SaveData.flashing)
				titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				MusicBeatState.switchState(new EvilMainMenuState());
			});
		}

		if (pressedEnter && !skippedIntro && initialized)
			skipIntro();

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if (credGroup != null && textGroup != null)
			{
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if (textGroup != null && credGroup != null)
		{
			var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; // Basically curBeat but won't be skipped if you hold the tab or resize the screen

	public static var closedState:Bool = false;

	override function beatHit()
	{
		super.beatHit();

		if (!closedState)
		{
			sickBeats++;

			switch (sickBeats)
			{
				case 1:
					createCoolText([''], 15);

				case 3:
					addMoreText('Team TBD', 15);

				case 5:
					tbdSpr.visible = true;

				case 7:
					deleteCoolText();
					tbdSpr.visible = false;

				case 8:
					createCoolText([curWacky[0]]);

				case 10:
					addMoreText(curWacky[1]);

				case 12:
					deleteCoolText();

				case 13:
					addMoreText('DDTO');

				case 14:
					addMoreText('Bad');

				case 15:
					addMoreText('Ending');

				case 16:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(tbdSpr);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
		}
	}
}