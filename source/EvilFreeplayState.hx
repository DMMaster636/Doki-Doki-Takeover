package;

import Song.SwagSong;
import flixel.addons.display.FlxBackdrop;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.effects.FlxFlicker;
import flixel.addons.transition.FlxTransitionableState;
import flixel.input.mouse.FlxMouseEventManager;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end

using StringTools;

class EvilFreeplayState extends MusicBeatState
{
	public static var instance:EvilFreeplayState;
	public var acceptInput:Bool = true;

	var songs:Array<SongMetadataEvil> = [];

	var selector:FlxText;

	var curSelected:Int = 0;
	var isDiffSelect:Bool = false;
	var curDifficulty:Int = 0;

	var sayori:FlxSprite;
	var natsuki:FlxSprite;
	var yuri:FlxSprite;

	var sayoritween:FlxTween;
	var natsukitween:FlxTween;
	var yuritween:FlxTween;
	var redStatic:FlxSprite;
	var redoverlay:FlxSprite;

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Float = 0;
	var intendedScore:Float = 0;

	var songname:FlxText;
	var diffstuff:FlxText;
	var vignette:FlxSprite;

	var bg:FlxSprite;

	var difficulties:Array<String> = ['Hard', 'Unfair'];
	public static var songData:Map<String, Array<SwagSong>> = [];

	var selectedSomethin:Bool = false;

	public static function loadDiff(diff:Int, name:String, array:Array<SwagSong>)
	{
		try
		{
			array.push(Song.loadFromJson(Highscore.formatSong(name, diff), name));
		}
		catch (ex)
		{
		}
	}

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		instance = this;

		if (!FlxG.sound.music.playing && !SaveData.cacheSong)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			Conductor.changeBPM(82.5);
		}

		PlayState.isStoryMode = false;

		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Freeplay Menu", null);
		#end

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('data/freeplay/badEnding'));

		for (i in 0...initSonglist.length)
		{
			var data:Array<String> = initSonglist[i].split(':');
			var meta = new SongMetadataEvil(data[0], Std.parseInt(data[2]), data[1]);

			var diffs = [];
			loadDiff(0, meta.songName, diffs);
			loadDiff(1, meta.songName, diffs);
			loadDiff(2, meta.songName, diffs);
			songData.set(meta.songName, diffs);

			if ((Std.parseInt(data[2]) <= SaveData.weekUnlocked - 1) || (Std.parseInt(data[2]) == 1))
				songs.push(meta);
		}

		var evilSpace:FlxBackdrop = new FlxBackdrop(Paths.image('bigmonika/Sky', 'doki'));
		evilSpace.velocity.set(-10, 0);
		evilSpace.antialiasing = SaveData.globalAntialiasing;
		add(evilSpace);

		bg = new FlxSprite().loadGraphic(Paths.image('bigmonika/BG', 'doki'));
		bg.setPosition(-239, -3);
		bg.antialiasing = SaveData.globalAntialiasing;
		add(bg);

		redStatic = new FlxSprite(0, 0);
		redStatic.frames = Paths.getSparrowAtlas('ruinedclub/HomeStatic', 'doki');
		redStatic.antialiasing = SaveData.globalAntialiasing;
		redStatic.animation.addByPrefix('hard', 'HomeStatic', 24);
		redStatic.animation.play('hard');
		redStatic.alpha = 0.001;
		add(redStatic);

		natsuki = new FlxSprite().loadGraphic(Paths.image('freeplay/natsu', 'preload'));
		natsuki.setPosition(37, 0);
		natsuki.antialiasing = SaveData.globalAntialiasing;
		add(natsuki);

		yuri = new FlxSprite().loadGraphic(Paths.image('freeplay/yuri', 'preload'));
		yuri.setPosition(177, 0);
		yuri.antialiasing = SaveData.globalAntialiasing;
		add(yuri);

		sayori = new FlxSprite().loadGraphic(Paths.image('freeplay/sayso', 'preload'));
		sayori.setPosition(107, 0);
		sayori.antialiasing = SaveData.globalAntialiasing;
		add(sayori);

		vignette = new FlxSprite(0, 0).loadGraphic(Paths.image('menuvignette'));
		vignette.alpha = 0.8;
		add(vignette);

		redoverlay = new FlxSprite(0, 0);
		redoverlay.frames = Paths.getSparrowAtlas('ruinedclub/HomeStatic', 'doki');
		redoverlay.antialiasing = SaveData.globalAntialiasing;
		redoverlay.animation.addByPrefix('hard', 'HomeStatic', 24);
		redoverlay.animation.play('hard');
		redoverlay.alpha = 0.001;
		add(redoverlay);

		songname = new FlxText(0, 550, 0, 'hueh', 50);
		songname.screenCenter(X);
		songname.font = LangUtil.getFont('animal');
		songname.color = 0xFFFFFFFF;
		songname.setBorderStyle(OUTLINE, FlxColor.BLACK, 3, 1);
		songname.antialiasing = SaveData.globalAntialiasing;
		add(songname);

		diffstuff = new FlxText(0, 600, 1280, 'hueh', 72);
		diffstuff.font = LangUtil.getFont('animal');
		diffstuff.color = 0xFFFFFFFF;
		diffstuff.alignment = CENTER;
		diffstuff.setBorderStyle(OUTLINE, FlxColor.BLACK, 3, 1);
		diffstuff.antialiasing = SaveData.globalAntialiasing;
		diffstuff.visible = false;
		diffstuff.screenCenter(X);
		add(diffstuff);

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 56, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		if (curSelected >= songs.length)
			curSelected = 0;

		changeSelection();
		changeDiff();

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		#if PRELOAD_ALL
		var leText:String = "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 16;
		#else
		var leText:String = "Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 18;
		#end
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);
		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadataEvil(songName, weekNum, songCharacter));
	}

	override function closeSubState()
	{
		changeSelection(0);
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		lerpScore = Math.abs(FramerateTools.lerpConvert(lerpScore, intendedScore, 0.4));

		scoreText.text = LangUtil.getString('cmnPB') + ': ' + Math.round(lerpScore);

		if (FlxG.sound.music != null && FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		positionHighscore();

		if (!selectedSomethin && acceptInput)
		{
			var shiftMult:Int = 1;
			if (FlxG.keys.pressed.SHIFT)
				shiftMult = 3;

			if (controls.RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				if (!isDiffSelect)
					changeSelection(-shiftMult);
				else
					changeDiff(1);
			}
			if (controls.LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				if (!isDiffSelect)
					changeSelection(shiftMult);
				else
					changeDiff(-1);
			}

			// Something barebones to hold off from playing the song
			// until you hit spacebar
			// Barebones because it's something quick that I could think of before doing other things
			if (FlxG.keys.justPressed.SPACE && !SaveData.cacheSong)
				playSong();

			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				if (!isDiffSelect)
					MusicBeatState.switchState(new EvilMainMenuState());
				else
				{
					selectedSomethin = false;
					isDiffSelect = false;
					diffstuff.visible = false;
					// Hide diff select here
				}
			}

			if (FlxG.keys.justPressed.CONTROL)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				openSubState(new DokiModifierSubState());
			}

			if (controls.ACCEPT && songs.length >= 1)
			{
				startsong();
			}
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);
	}

	public function startsong()
	{
		selectedSomethin = true;
		FlxG.sound.play(Paths.sound('confirmMenu'));
		loadSong();
	}

	function loadSong(isCharting:Bool = false)
	{
		var poop:String = Highscore.formatSong(songs[curSelected].songName, curDifficulty);

		PlayState.isStoryMode = false;

		try
		{
			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			PlayState.storyDifficulty = curDifficulty + 1;
		}
		catch (e)
		{
			poop = Highscore.formatSong(songs[curSelected].songName, 1);
			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			PlayState.storyDifficulty = 2;
		}

		PlayState.storyWeek = songs[curSelected].week;

		if (FlxG.keys.pressed.P)
			PlayState.practiceMode = true;

		// force disable dialogue
		if (FlxG.keys.pressed.F)
			PlayState.ForceDisableDialogue = true;

		if (isCharting)
			LoadingState.loadAndSwitchState(new ChartingState());
		else
			LoadingState.loadAndSwitchState(new PlayState());
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = difficulties.length - 1;
		if (curDifficulty >= difficulties.length)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffstuff.text = '< ' + difficulties[curDifficulty] + ' >';
		positionHighscore();

		swapstyle(curDifficulty);
	}

	function swapstyle(hueh:Int)
	{
		redoverlay.alpha = 0.7;
		FlxTween.cancelTweensOf(redoverlay);
		FlxTween.tween(redoverlay, {alpha: 0.0001}, 0.25);
		if (difficulties[curDifficulty].toLowerCase() == 'unfair' && hueh == 1)
		{
			trace("funny harder moder ");
			redStatic.alpha = 1;
			natsuki.loadGraphic(Paths.image('freeplay/natsuunfair', 'preload'));
			yuri.loadGraphic(Paths.image('freeplay/yuriunfair', 'preload'));
			sayori.loadGraphic(Paths.image('freeplay/saysounfair', 'preload'));
		}
		else
		{
			trace("goku goes supersaiyan ");
			redStatic.alpha = 0.001;
			natsuki.loadGraphic(Paths.image('freeplay/natsu', 'preload'));
			yuri.loadGraphic(Paths.image('freeplay/yuri', 'preload'));
			sayori.loadGraphic(Paths.image('freeplay/sayso', 'preload'));
		}
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		PlayState.storyWeek = songs[curSelected].week;

		songname.text = songs[curSelected].songName.toLowerCase();
		songname.screenCenter(X);

		if (sayoritween != null)
		{
			sayoritween.cancel();
			natsukitween.cancel();
			yuritween.cancel();	
		}

		switch (songs[curSelected].songName.toLowerCase())
		{
			case 'stagnant':
				yuritween = FlxTween.tween(yuri, {x: 177}, 0.25);
				natsukitween = FlxTween.tween(natsuki, {x: 37}, 0.25);
				
				yuritween = FlxTween.color(yuri, 0.25, yuri.color, 0xFF444444);
				natsukitween = FlxTween.color(natsuki, 0.25, natsuki.color, 0xFF444444);
				sayoritween = FlxTween.color(sayori, 0.25, sayori.color, 0xFFffffff);
			case 'home':
				yuritween = FlxTween.tween(yuri, {x: 177}, 0.25);
				natsukitween = FlxTween.tween(natsuki, {x: 107}, 0.25);

				yuritween = FlxTween.color(yuri, 0.25, yuri.color, 0xFF444444);
				natsukitween = FlxTween.color(natsuki, 0.25, natsuki.color, 0xFFffffff);
				sayoritween = FlxTween.color(sayori, 0.25, sayori.color, 0xFF444444);
			case 'markov':
				yuritween = FlxTween.tween(yuri, {x: 107}, 0.25);
				natsukitween = FlxTween.tween(natsuki, {x: 37}, 0.25);

				yuritween = FlxTween.color(yuri, 0.25, yuri.color, 0xFFffffff);
				natsukitween = FlxTween.color(natsuki, 0.25, natsuki.color, 0xFF444444);
				sayoritween = FlxTween.color(sayori, 0.25, sayori.color, 0xFF444444);
			default:
				yuritween = FlxTween.tween(yuri, {x: 177}, 0.25);
				natsukitween = FlxTween.tween(natsuki, {x: 37}, 0.25);

				yuritween = FlxTween.color(yuri, 0.25, yuri.color, 0xFF444444);
				natsukitween = FlxTween.color(natsuki, 0.25, natsuki.color, 0xFF444444);
				sayoritween = FlxTween.color(sayori, 0.25, sayori.color, 0xFF444444);
		}
	}

	function playSong()
	{
		FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), SaveData.cacheSong ? 0 : 1);

		var hmm;
		try
		{
			hmm = songData.get(songs[curSelected].songName)[0]; // curDifficulty
			if (hmm != null)
				Conductor.changeBPM(hmm.bpm);
		}
		catch (ex)
		{
			Conductor.changeBPM(102);
		}
	}

	private function positionHighscore()
	{
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}
}

class SongMetadataEvil
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}