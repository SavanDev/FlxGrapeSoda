package objects;

import Discord.State;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

enum Style
{
	Coin;
	Dollar;
}

class Money extends FlxSprite
{
	var style:Style;

	public function new(_x:Float, _y:Float, _style:Style = Style.Coin)
	{
		super(_x, _y);
		switch (_style)
		{
			case Coin:
				loadGraphic(Paths.getImage("items/coin"), true, 12, 12);
			case Dollar:
				loadGraphic(Paths.getImage("items/dollar"), false, 12, 12);
				FlxTween.num(_y, _y + 2, .5, {type: PINGPONG}, (v:Float) -> this.setPosition(_x, v));
		}

		animation.add("default", [0, 1], 10);
		animation.play("default");
		style = _style;
	}

	override function kill()
	{
		switch (style)
		{
			case Coin:
				Gameplay.MONEY += 2;
			case Dollar:
				Gameplay.MONEY += 100;
		}

		alive = false;
		FlxG.sound.play(Paths.getSound("coin"));

		if (Gameplay.HUD != null)
			Gameplay.HUD.updateMoneyCounter(Gameplay.MONEY);

		FlxTween.tween(this, {alpha: 0, y: y - 16}, .33, {
			ease: FlxEase.circOut,
			onComplete: function(_)
			{
				exists = false;
			}
		});
	}
}
