import flixel.FlxG;
import flixel.FlxState;

class GameBaseState extends FlxState
{
	override public function create()
	{
		super.create();
		FlxG.camera.pixelPerfectRender = true;
	}
}
