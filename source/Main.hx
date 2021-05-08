package;

import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();

		#if android
		addChild(new FlxGame(250, 144, MenuState));
		#else
		addChild(new FlxGame(160, 144, MenuState));
		#end

		#if debug
		addChild(new FPS(5, 5, 0xFFFFFF));
		#end
	}
}
