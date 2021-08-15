package;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class HUD extends FlxTypedGroup<FlxSprite>
{
	var initialY:Int = 5;
	var spacingY:Int = 13;

	var moneyCounter:FlxBitmapText;
	var timeCounter:FlxBitmapText;
	var enemyCounter:FlxBitmapText;
	var liveCounter:FlxBitmapText;

	var timer:Int;
	var minutes:Int;
	var seconds:Int;
	var miliseconds:Int;

	public function new()
	{
		super();

		// iconos
		var moneyIcon = new FlxSprite(5, initialY);
		moneyIcon.loadGraphic(Paths.getImage("items/coin"), true, 12, 12);
		moneyIcon.animation.add("default", [0, 1], 5);
		moneyIcon.animation.play("default");
		var timeIcon = new FlxSprite(5, initialY + spacingY, Paths.getImage("items/time"));
		var enemyIcon = new FlxSprite(5, initialY + (spacingY * 2), Paths.getImage("items/enemy"));
		var liveIcon = new FlxSprite(5, initialY + (spacingY * 3), Paths.getImage("items/live"));
		add(moneyIcon);
		add(timeIcon);
		add(enemyIcon);
		add(liveIcon);

		// texto
		moneyCounter = new FlxBitmapText(Fonts.DEFAULT);
		moneyCounter.text = Std.string(PlayState.MONEY);
		moneyCounter.setPosition(18, initialY + 1);
		moneyCounter.setBorderStyle(SHADOW, FlxColor.BLACK, 1, 1);
		moneyCounter.useTextColor = true;
		timeCounter = new FlxBitmapText(Fonts.DEFAULT);
		timeCounter.setPosition(18, initialY + spacingY + 1);
		timeCounter.setBorderStyle(SHADOW, FlxColor.BLACK, 1, 1);
		enemyCounter = new FlxBitmapText(Fonts.DEFAULT);
		enemyCounter.text = Std.string(PlayState.ENEMIES_DEAD);
		enemyCounter.setPosition(18, initialY + (spacingY * 2) + 1);
		enemyCounter.setBorderStyle(SHADOW, FlxColor.BLACK, 1, 1);
		enemyCounter.useTextColor = true;
		liveCounter = new FlxBitmapText(Fonts.DEFAULT);
		liveCounter.text = "5";
		liveCounter.setPosition(18, initialY + (spacingY * 3) + 1);
		liveCounter.setBorderStyle(SHADOW, FlxColor.BLACK, 1, 1);
		add(moneyCounter);
		add(timeCounter);
		add(enemyCounter);
		add(liveCounter);
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
		liveCounter.text = Std.string(Player.LIVES);

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
