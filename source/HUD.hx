package;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class HUD extends FlxTypedGroup<FlxSprite>
{
	var moneyCounter:FlxBitmapText;
	var timeCounter:FlxBitmapText;
	var moneyIcon:FlxSprite;
	var timeIcon:FlxSprite;

	var timer:Int;
	var minutes:Int;
	var seconds:Int;

	public function new()
	{
		super();

		// iconos
		moneyIcon = new FlxSprite(5, 5);
		moneyIcon.loadGraphic(Paths.getImage("items/coin"), true, 12, 12);
		moneyIcon.animation.add("default", [0, 1], 5);
		moneyIcon.animation.play("default");
		timeIcon = new FlxSprite(5, 18, Paths.getImage("items/time"));
		add(moneyIcon);
		add(timeIcon);

		// texto
		moneyCounter = new FlxBitmapText(Fonts.DEFAULT);
		moneyCounter.text = Std.string(PlayState.MONEY);
		moneyCounter.setPosition(18, 6);
		moneyCounter.setBorderStyle(SHADOW, FlxColor.BLACK, 1, 1);
		moneyCounter.useTextColor = true;
		timeCounter = new FlxBitmapText(Fonts.DEFAULT);
		timeCounter.setPosition(18, 19);
		timeCounter.setBorderStyle(SHADOW, FlxColor.BLACK, 1, 1);
		add(moneyCounter);
		add(timeCounter);
		forEach(function(sprite) sprite.scrollFactor.set(0, 0));
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (moneyCounter.text != Std.string(PlayState.MONEY))
		{
			moneyCounter.textColor = 0xFF008300;
			new FlxTimer().start(.5, function(timer:FlxTimer)
			{
				moneyCounter.textColor = FlxColor.WHITE;
			});
		}

		moneyCounter.text = Std.string(PlayState.MONEY);

		timer = Math.floor(PlayState.TIME);
		minutes = Std.int(timer / 60);
		seconds = timer - (minutes * 60);

		var minutesText:String = minutes < 10 ? '0$minutes' : '$minutes';
		var secondsText:String = seconds < 10 ? '0$seconds' : '$seconds';

		timeCounter.text = '$minutesText:$secondsText';
	}
}
