package;

import flixel.FlxGame;
import flixel.FlxState;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	var _width:Int = Game.WIDTH;
	var _height:Int = Game.HEIGHT;
	var _initialState:Class<FlxState> = SavanLogo;

	public function new()
	{
		super();
		addChild(new FlxGame(_width, _height, _initialState));
		Input.init();

		#if debug
		addChild(new FPS(5, 5, 0xFFFFFF));
		#end
	}
}
