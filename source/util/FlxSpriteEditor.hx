package util;

import editor.EditorState;
import flixel.FlxG;
import flixel.FlxSprite;

class FlxSpriteEditor extends FlxSprite
{
	var entityType:Int;

	public function new(?X:Float = 0, ?Y:Float = 0, Type:Int)
	{
		super(X, Y);
		entityType = Type;
	}

	public function getEntityType()
	{
		return entityType;
	}
}
