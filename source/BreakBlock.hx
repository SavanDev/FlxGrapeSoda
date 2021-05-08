package;

import flixel.FlxG;
import flixel.FlxSprite;

class BreakBlock extends FlxSprite
{
	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		loadGraphic(Paths.getImage("breakBlock"), true, 12, 24);
		health = 2;
		animation.add("default", [0]);
		animation.add("break", [1]);
		animation.play("default");
		immovable = true;
	}

	override public function hurt(amount:Float)
	{
		health -= amount;
		FlxG.sound.play(Paths.getSound("hit"));
		trace('Block damage! HP: $health');

		if (health <= 1)
			animation.play("break");

		if (health <= 0)
			kill();
	}
}
