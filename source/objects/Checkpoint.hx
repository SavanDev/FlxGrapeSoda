package objects;

import flixel.FlxSprite;

class Checkpoint extends FlxSprite
{
	public var checked:Bool = false;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		loadGraphic(Paths.getImage('objects/check'), true, 12, 12);
	}
}
