package;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class CloseGameSubState extends MusicBeatSubstate
{
	var isExit:Bool = true;
	var selectGrp:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();

	public function new()
	{
		super();

		var background:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		background.alpha = 0.5;
		add(background);

		var box:FlxSprite = new FlxSprite().loadGraphic(Paths.image('popup_blank'));
		box.antialiasing = SaveData.globalAntialiasing;
		box.updateHitbox();
		box.screenCenter();
		add(box);

		var text:FlxText = new FlxText(0, box.y + 76, box.frameWidth * 0.95, LangUtil.getString('cmnExit'));
		text.setFormat(LangUtil.getFont('aller'), 32, FlxColor.BLACK, FlxTextAlign.CENTER);
		text.y += LangUtil.getFontOffset('aller');
		text.screenCenter(X);
		text.antialiasing = SaveData.globalAntialiasing;
		add(text);

		var textYes:FlxText = new FlxText(box.x + (box.width * 0.18), box.y + (box.height * 0.65), 0, LangUtil.getString('cmnYes'));
		textYes.setFormat(LangUtil.getFont('riffic'), 48, FlxColor.WHITE, FlxTextAlign.CENTER);
		textYes.y += LangUtil.getFontOffset('riffic');
		textYes.antialiasing = SaveData.globalAntialiasing;
		textYes.setBorderStyle(OUTLINE, 0xFFFF7CFF, 3);
		textYes.ID = 0;

		var textNo:FlxText = new FlxText(box.x + (box.width * 0.7), box.y + (box.height * 0.65), 0, LangUtil.getString('cmnNo'));
		textNo.setFormat(LangUtil.getFont('riffic'), 48, FlxColor.WHITE, FlxTextAlign.CENTER);
		textNo.y += LangUtil.getFontOffset('riffic');
		textNo.antialiasing = SaveData.globalAntialiasing;
		textNo.setBorderStyle(OUTLINE, 0xFFFFCFFF, 3);
		textNo.ID = 1;

		selectGrp.add(textYes);
		selectGrp.add(textNo);
		add(selectGrp);
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (controls.BACK) {
			isExit = false;
			selectItem();
		}

		if (controls.LEFT_P || controls.RIGHT_P) {

			FlxG.sound.play(Paths.sound('scrollMenu'));

			isExit = !isExit;

			selectGrp.forEach(function(txt:FlxText)
			{
				if (txt.ID == (isExit ? 1 : 0))
					txt.setBorderStyle(OUTLINE, 0xFFFFCFFF, 3);
				else
					txt.setBorderStyle(OUTLINE, 0xFFFF7CFF, 3);
			});
		}

		if (controls.ACCEPT)
			selectItem();
	}

	function selectItem():Void
	{
		if (isExit)
		{
			Sys.exit(0);
		}
		else
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.resetState();
			close();
		}
	}
}
