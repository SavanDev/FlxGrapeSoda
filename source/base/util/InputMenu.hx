package util;

import flixel.FlxG;
import flixel.group.FlxGroup;
import openfl.events.KeyboardEvent;

class InputMenu extends FlxGroup
{
	var numberTyped:String;

	public function new()
	{
		super();
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	}

	function onKeyDown(ev:KeyboardEvent)
	{
		if (ev.charCode >= 48 && ev.charCode <= 57)
			trace("is a number!");
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
