package;

import flixel.FlxGame;
import flixel.FlxState;
import openfl.display.Sprite;
import util.FPSMem;

class Main extends Sprite
{
	var _width:Int = 250;
	var _height:Int = 144;
	var _initialState:Class<FlxState> = SavanLogo;

	public function new()
	{
		super();
		addChild(new FlxGame(_width, _height, _initialState));
		Input.init();

		#if debug
		addChild(new FPSMem(5, 5, 0xFFFFFF));
		#end
	}
}
