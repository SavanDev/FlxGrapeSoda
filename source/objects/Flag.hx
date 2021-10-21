package objects;

import flixel.FlxSprite;

class Flag extends FlxSprite
{
	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		loadGraphic(Paths.getImage("items/flag"), true, 24, 48);
		animation.add("default", [0, 1, 2, 3], 10);
		animation.play("default");
	}
}
