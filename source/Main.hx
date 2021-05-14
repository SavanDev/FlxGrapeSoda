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
		addChild(new FlxGame(250, 144, SavanLogo));
		#else
		addChild(new FlxGame(160, 144, SavanLogo));
		#end

		#if debug
		addChild(new FPS(5, 5, 0xFFFFFF));
		#end
	}
}
