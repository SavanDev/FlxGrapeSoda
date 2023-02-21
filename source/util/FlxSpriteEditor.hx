package util;

import flixel.FlxG;
import flixel.FlxSprite;

class FlxSpriteEditor extends FlxSprite
{
	var entityType(default, set):Int;

	public var message:String;

	public function new(Type:Int, ?X:Float = 0, ?Y:Float = 0)
	{
		super(X, Y);
		entityType = Type;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function getEntityType()
	{
		return entityType;
	}

	public function getEntityName(value:Int):String
	{
		switch (value)
		{
			case 0:
				return "PLAYER";
			case 1:
				return "ENEMY - PICKY";
			case 2:
				return "COIN";
			case 3:
				return "FLAG";
			case 4:
				return "BREAKABLE BLOCK";
			case 5:
				return "SIGN";
			case 6:
				return "CHECKPOINT";
			default:
				return "NULL";
		}
	}

	public function setEntityType(value:Int)
	{
		entityType = value;
	}

	/*
		Entity ID:
		0 -> Player
		1 -> Enemy
		2 -> Coin
		3 -> Flag
		4 -> Breakable block
		5 -> Sign
		6 -> Checkpoint
	 */
	function set_entityType(value:Int):Int
	{
		switch (value)
		{
			case 0:
				loadGraphic(Paths.getImage('player'), true, 12, 24);
			case 1:
				loadGraphic(Paths.getImage('enemies/picky'), true, 12, 12);
			case 2:
				loadGraphic(Paths.getImage('items/coin'), true, 12, 12);
			case 3:
				loadGraphic(Paths.getImage('objects/flag'), true, 24, 48);
			case 4:
				loadGraphic(Paths.getImage('objects/breakableBlock'), true, 12, 24);
			case 5:
				loadGraphic(Paths.getImage('objects/sign'), false, 12, 12);
			case 6:
				loadGraphic(Paths.getImage('objects/check'), true, 12, 12);
		}
		return entityType = value;
	}
}
