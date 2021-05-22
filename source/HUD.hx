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
	var enemyCounter:FlxBitmapText;
	var enemyIcon:FlxSprite;

	var timer:Int;
	var minutes:Int;
	var seconds:Int;
	var miliseconds:Int;

	public function new()
	{
		super();

		// iconos
		moneyIcon = new FlxSprite(5, 5);
		moneyIcon.loadGraphic(Paths.getImage("items/coin"), true, 12, 12);
		moneyIcon.animation.add("default", [0, 1], 5);
		moneyIcon.animation.play("default");
		timeIcon = new FlxSprite(5, 18, Paths.getImage("items/time"));
		enemyIcon = new FlxSprite(5, 31, Paths.getImage("items/enemy"));
		add(moneyIcon);
		add(timeIcon);
		add(enemyIcon);

		// texto
		moneyCounter = new FlxBitmapText(Fonts.DEFAULT);
		moneyCounter.text = Std.string(PlayState.MONEY);
		moneyCounter.setPosition(18, 6);
		moneyCounter.setBorderStyle(SHADOW, FlxColor.BLACK, 1, 1);
		moneyCounter.useTextColor = true;
		timeCounter = new FlxBitmapText(Fonts.DEFAULT);
		timeCounter.setPosition(18, 19);
		timeCounter.setBorderStyle(SHADOW, FlxColor.BLACK, 1, 1);
		enemyCounter = new FlxBitmapText(Fonts.DEFAULT);
		enemyCounter.text = Std.string(PlayState.ENEMIES_DEAD);
		enemyCounter.setPosition(18, 32);
		enemyCounter.setBorderStyle(SHADOW, FlxColor.BLACK, 1, 1);
		enemyCounter.useTextColor = true;
		add(moneyCounter);
		add(timeCounter);
		add(enemyCounter);
		// forEach(function(sprite) sprite.scrollFactor.set(0, 0));
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

		if (enemyCounter.text != Std.string(PlayState.ENEMIES_DEAD))
		{
			enemyCounter.textColor = FlxColor.RED;
			new FlxTimer().start(.5, function(timer:FlxTimer)
			{
				enemyCounter.textColor = FlxColor.WHITE;
			});
		}

		moneyCounter.text = Std.string(PlayState.MONEY);
		enemyCounter.text = Std.string(PlayState.ENEMIES_DEAD);

		timer = Math.floor(PlayState.TIME * 100);
		minutes = Std.int(timer / 100 / 60);
		seconds = Std.int(timer / 100) - (minutes * 60);
		miliseconds = timer - ((seconds + (minutes * 60)) * 100);

		var minutesText:String = minutes < 10 ? '0$minutes' : '$minutes';
		var secondsText:String = seconds < 10 ? '0$seconds' : '$seconds';
		var milisecondsText:String = miliseconds < 10 ? '0$miliseconds' : '$miliseconds';

		timeCounter.text = '$minutesText:$secondsText.$milisecondsText';
	}
}
