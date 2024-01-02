package;

import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouseEventManager;
import Controls.KeyboardScheme;
import haxe.Json;
import lime.utils.Assets;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup;
import flixel.effects.FlxFlicker;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import flixel.group.FlxGroup.FlxTypedGroup;
import shaders.ColorMaskShader;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end
#if FEATURE_GAMEJOLT
import GameJolt.GameJoltAPI;
#end

using StringTools;

class EvilMainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	// I guess this needs to be a thing now
	// because originally, it used to be "FlxMouseEventManager.add"
	// but now you gotta put it in a variable manager.
	// Guessing this is a flixel update issue, but whatever. ~ Codexes
	var mouseManager:FlxMouseEventManager = new FlxMouseEventManager();

	var menuItems:FlxTypedGroup<FlxText>;

	var optionShit:Array<String> = ['story mode', 'freeplay', 'credits', 'options', 'exit', 'switch'];

	public static var firstStart:Bool = true;

	public var acceptInput:Bool = true;

	var logo:FlxSprite;
	var menu_character:FlxSprite;

	var backdrop:FlxBackdrop;
	var logoBl:FlxSprite;
	var vignette:FlxSprite;
	var oof:FlxSprite;

	public static var instance:EvilMainMenuState;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		instance = this;

		persistentUpdate = persistentDraw = true;

		FlxG.mouse.visible = true;

		if (!SaveData.beatBadEnding) {
			optionShit.remove('freeplay');
			optionShit.remove('credits');
		}

		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('menuEvil'));
			Conductor.changeBPM(82.5);
		}

		backdrop = new FlxBackdrop(Paths.image('scrolling_BG'));
		backdrop.velocity.set(-40, -40);
		backdrop.antialiasing = SaveData.globalAntialiasing;
		add(backdrop);

		var random:Int = FlxG.random.int(1, 100);
		trace(random);

		if (random == 64)
		{
			// Can't let my child go to waste :)
			menu_character = new FlxSprite(-100, -250).loadGraphic(Paths.image('FumoEvil'));
			menu_character.screenCenter();
			menu_character.x += 100;
		}
		else menu_character = new FlxSprite(460, 0).loadGraphic(Paths.image('GhostDokis'));
		menu_character.antialiasing = SaveData.globalAntialiasing;
		menu_character.updateHitbox();
		add(menu_character);

		logo = new FlxSprite(-260, 0).loadGraphic(Paths.image('Credits_LeftSide_Bad'));
		logo.antialiasing = SaveData.globalAntialiasing;
		add(logo);
		if (firstStart)
			FlxTween.tween(logo, {x: -60}, 1.2, {
				ease: FlxEase.elasticOut,
				onComplete: function(flxTween:FlxTween)
				{
					firstStart = false;
					changeItem();
				}
			});
		else
			logo.x = -60;

		logoBl = new FlxSprite(-160, -40);
		logoBl.frames = Paths.getSparrowAtlas('logoBadEnding');
		logoBl.antialiasing = SaveData.globalAntialiasing;
		logoBl.scale.set(0.5, 0.5);
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		add(logoBl);
		if (firstStart)
			FlxTween.tween(logoBl, {x: 40}, 1.2, {
				ease: FlxEase.elasticOut,
				onComplete: function(flxTween:FlxTween)
				{
					firstStart = false;
					changeItem();
				}
			});
		else
			logoBl.x = 40;

		menuItems = new FlxTypedGroup<FlxText>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxText = new FlxText(-350, 370 + (i * 50), 0, LangUtil.getString(optionShit[i], 'menu'));
			menuItem.setFormat(LangUtil.getFont('riffic'), 27, FlxColor.WHITE, LEFT);
			menuItem.antialiasing = SaveData.globalAntialiasing;
			menuItem.setBorderStyle(OUTLINE, 0xFF444444, 2);
			menuItem.ID = i;
			if (optionShit[i] == 'switch') menuItem.visible = false;
			menuItems.add(menuItem);

			if (firstStart)
				FlxTween.tween(menuItem, {x: 50}, 1.2 + (i * 0.2), {
					ease: FlxEase.elasticOut,
					onComplete: function(flxTween:FlxTween)
					{
						firstStart = false;
						changeItem();
					}
				});
			else
				menuItem.x = 50;

			// Add menu item into mouse manager, so it can be selected by cursor
			mouseManager.add(menuItem, onMouseDown, null, onMouseOver);
		}

		add(mouseManager);

		var versionShit:FlxText = new FlxText(-350, FlxG.height - 24, 0, "v1.5.1", 12);
		versionShit.scrollFactor.set();
		versionShit.antialiasing = SaveData.globalAntialiasing;
		versionShit.setFormat(LangUtil.getFont('aller'), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.y += LangUtil.getFontOffset('aller');
		add(versionShit);

		oof = new FlxSprite(0, 0).loadGraphic(Paths.image('DonTabOut'));
		oof.screenCenter();
		oof.alpha = 0.0001;
		add(oof);

		vignette = new FlxSprite(0, 0).loadGraphic(Paths.image('menuvignette'));
		vignette.alpha = 0.6;
		add(vignette);

		if (firstStart)
			FlxTween.tween(versionShit, {x: 5}, 1.2, {
				ease: FlxEase.elasticOut,
				onComplete: function(flxTween:FlxTween)
				{
					firstStart = false;
					changeItem();
				}
			});
		else
			versionShit.x = 5;

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (!selectedSomethin && acceptInput)
		{
			if (logoBl != null && FlxG.mouse.overlaps(logoBl) && FlxG.mouse.justPressed)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				switchToDDTO();
			}

			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}
				
			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}	
			
			if (controls.RESET)
				MusicBeatState.resetState();

			#if debug
			if (FlxG.keys.justPressed.O)
				SaveData.unlockAll();

			if (FlxG.keys.justPressed.P)
				SaveData.unlockAll(false);
			#end

			if (controls.ACCEPT)
				selectThing();
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);
	}

	function goToState()
	{
		var daChoice:String = optionShit[curSelected];

		switch (daChoice)
		{
			case 'story mode':
				loadStoryWeek();
				trace("Story Menu Selected");
			case 'freeplay':
				MusicBeatState.switchState(new EvilFreeplayState());
				trace("Freeplay Menu Selected");
			case 'credits':
				if (FlxG.keys.pressed.G)
				{
					CoolUtil.openURL('https://www.youtube.com/watch?v=0MW9Nrg_kZU');
					FlxG.resetState();
				} else
					MusicBeatState.switchState(new EvilCreditsState());
				trace("Credits Menu Selected");
			case 'options':
				MusicBeatState.switchState(new OptionsState());
			case 'exit':
				openSubState(new CloseGameSubState());
			case 'switch':
				switchToDDTO();
		}
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= optionShit.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = optionShit.length - 1;

		menuItems.forEach(function(txt:FlxText)
		{
			if (txt.ID == curSelected)
				txt.setBorderStyle(OUTLINE, 0xFFFF0513, 2);
			else
				txt.setBorderStyle(OUTLINE, 0xFF444444, 2);
		});
	}

	function selectThing():Void
	{
		acceptInput = false;
		selectedSomethin = true;
		FlxG.sound.play(Paths.sound('confirmMenu'));

		menuItems.forEach(function(txt:FlxText)
		{
			if (curSelected != txt.ID)
			{
				FlxTween.tween(txt, {alpha: 0}, 1.3, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						txt.kill();
					}
				});
			}
			else
			{
				if (SaveData.flashing)
				{
					FlxFlicker.flicker(txt, 1, 0.06, false, false, function(flick:FlxFlicker)
					{
						goToState();
					});
				}
				else
				{
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						goToState();
					});
				}
			}
		});
	}

	function switchToDDTO()
	{
		SaveData.badEndingSelected = false;
		SaveData.save();

		FlxG.sound.music.fadeOut(0.75, 0, function(twn:FlxTween)
		{
			FlxG.sound.music.stop();
		});
		TitleState.initialized = false;

		MusicBeatState.switchState(new TitleState());
	}

	function loadStoryWeek()
	{
		PlayState.storyPlaylist = ['STAGNANT', 'MARKOV', 'HOME'];
		PlayState.storyDifficulty = 2;

		PlayState.ForceDisableDialogue = false;
		PlayState.isStoryMode = true;
		selectedSomethin = true;

		var poop:String = Highscore.formatSong(PlayState.storyPlaylist[0], PlayState.storyDifficulty);

		try {
			PlayState.SONG = Song.loadFromJson(poop, PlayState.storyPlaylist[0].toLowerCase());
		} catch (e) {
			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + '-hard', PlayState.storyPlaylist[0].toLowerCase());
		}

		PlayState.storyWeek = 13;
		PlayState.campaignScore = 0;

		LoadingState.loadAndSwitchState(new PlayState(), true, true);
		trace('bad ending selected');
	}

	function onMouseDown(spr:FlxSprite):Void
	{
		if (!selectedSomethin && acceptInput)
			selectThing();
	}

	function onMouseOver(spr:FlxSprite):Void
	{
		if (!selectedSomethin && acceptInput)
		{
			if (curSelected != spr.ID)
				FlxG.sound.play(Paths.sound('scrollMenu'));
	
			if (!selectedSomethin)
				curSelected = spr.ID;
		}

		changeItem();
	}

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump', true);
	}

	var focused:Bool = true;
	var funnyTimer:FlxTimer;

	override public function onFocusLost():Void
	{
		trace('we tabbed out');
		if (focused == true)
		{
			focused = false;
			funnyTimer = new FlxTimer().start(5, function(tmr:FlxTimer)
			{
				FlxTween.tween(oof, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
			});
		}
		super.onFocusLost();
	}

	override public function onFocus():Void
	{
		trace('we tabbed in');
		if (focused == false)
		{
			funnyTimer.cancel();
			focused = true;
			FlxTween.cancelTweensOf(oof);
			FlxTween.tween(oof, {alpha: 0.0001}, 0.1, {ease: FlxEase.circOut});
		}
		super.onFocus();
	}
}
