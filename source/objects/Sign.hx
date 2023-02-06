package objects;

import flixel.FlxSprite;

class Sign extends FlxSprite
{
	public var message:String;

	public function new(x:Float = 0, y:Float = 0, text:String)
	{
		super(x, y);
		loadGraphic(Paths.getImage("objects/sign"), false, 12, 12);
		message = text;
	}
}
