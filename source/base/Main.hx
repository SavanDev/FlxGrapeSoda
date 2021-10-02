package;

import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;
import util.FPSMem;

class Main extends Sprite
{
	public function new()
	{
		super();
		#if mobile
		addChild(new FlxGame(250, 144, SavanLogo));
		#else
		addChild(new FlxGame(160, 144, SavanLogo));
		#end
		Input.init();

		#if debug
		addChild(new FPSMem(5, 5, 0xFFFFFF));
		#end
	}
}
