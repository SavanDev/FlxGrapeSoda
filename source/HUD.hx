package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import util.Timer;

class HUD extends FlxTypedGroup<FlxSprite>
{
	static final initialY:Int = 3;
	static final spacingY:Int = 13;

	static final moneyLength:Int = 5;
	static final totalLives:Int = 5;

	var moneyCounter:FlxBitmapText;
	var timeCounter:FlxBitmapText;
	var liveBar:FlxSpriteGroup;

	var minutes:Int;
	var seconds:Int;
	var miliseconds:Int;

	public function new()
	{
		super();

		// money
		moneyCounter = new FlxBitmapText(Fonts.TOY);
		updateMoneyCounter(PlayState.MONEY);
		moneyCounter.setPosition(FlxG.width - moneyCounter.width - 10, initialY);
		moneyCounter.setBorderStyle(SHADOW, FlxColor.BLACK, 1, 1);
		moneyCounter.useTextColor = true;
		add(moneyCounter);

		var moneyIcon = new FlxSprite(FlxG.width - 18, initialY + spacingY, Paths.getImage("hud/coin"));
		add(moneyIcon);

		// timer
		timeCounter = new FlxBitmapText(Fonts.TOY);
		timeCounter.setPosition(FlxG.width / 2, initialY);
		timeCounter.setBorderStyle(SHADOW, FlxColor.BLACK, 1, 1);
		updateTimer(Timer.getMinutes(), Timer.getSeconds());
		timeCounter.x -= timeCounter.width / 2;
		add(timeCounter);

		var timeIcon = new FlxSprite(FlxG.width / 2 - 4, initialY + spacingY, Paths.getImage("hud/time"));
		add(timeIcon);

		// lives
		liveBar = new FlxSpriteGroup(8, initialY + 5);
		for (i in 0...totalLives)
		{
			var live = new FlxSprite(i * 9, 0);
			live.loadGraphic(Paths.getImage("hud/live"), true, 8, 8);
			live.animation.frameIndex = (i + 1) <= Player.LIVES ? 0 : 1;
			liveBar.add(live);
		}
		add(liveBar);
		updateLivesCounter(Player.LIVES);
	}

	public function updateMoneyCounter(number:Int)
	{
		var count = Std.string(number);
		moneyCounter.text = writeZeros(moneyLength - count.length) + count;
		moneyCounter.textColor = 0xFF008300;
		new FlxTimer().start(.5, (tmr:FlxTimer) -> moneyCounter.textColor = FlxColor.WHITE);
	}

	public function updateLivesCounter(number:Int)
	{
		for (i in 0...totalLives)
		{
			if (i + 1 <= number)
				liveBar.members[i].animation.frameIndex = 0;
			else
				liveBar.members[i].animation.frameIndex = 1;

			// Esto es un lio... pero funciona
			new FlxTimer().start(.1 * i, (tmr) ->
			{
				FlxTween.num(liveBar.members[i].y, liveBar.members[i].y - 3, .25, {
					onComplete: (_) -> FlxTween.num(liveBar.members[i].y, liveBar.members[i].y + 3, .25, (v) -> liveBar.members[i].y = v)
				}, (v) -> liveBar.members[i].y = v);
			});
		}
		if (number == 1)
			new FlxTimer().start(.5, (tmr) ->
			{
				if (Player.LIVES > 1)
				{
					liveBar.visible = true;
					tmr.cancel();
				}
				else
					liveBar.visible = !liveBar.visible;
			}, 0);
	}

	public function updateTimer(minutes:Int = 0, seconds:Int = 0)
	{
		var minutesText:String = minutes < 10 ? '0$minutes' : '$minutes';
		var secondsText:String = seconds < 10 ? '0$seconds' : '$seconds';
		timeCounter.text = '$minutesText:$secondsText';
	}

	function writeZeros(left:Int) // Cobo, yo te banco!
	{
		if (left > 0)
			return "0" + writeZeros(left - 1);
		else
			return "0";
	}
}
