package util;

import editor.EditorState;
import flixel.FlxG;
import flixel.FlxSprite;

class FlxSpriteEditor extends FlxSprite
{
	var entityType(default, set):Int;

	public function new(Type:Int, ?X:Float = 0, ?Y:Float = 0)
	{
		super(X, Y);
		entityType = Type;
	}

	public function getEntityType()
	{
		return entityType;
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
	 */
	function set_entityType(value:Int):Int
	{
		switch (value)
		{
			case 0:
				loadGraphic(Paths.getImage('player'), true, 12, 24);
			case 1:
				loadGraphic(Paths.getImage('picky'), true, 12, 12);
			case 2:
				loadGraphic(Paths.getImage('items/coin'), true, 12, 12);
			case 3:
				loadGraphic(Paths.getImage('items/flag'), true, 24, 48);
		}
		return entityType = value;
	}
}
