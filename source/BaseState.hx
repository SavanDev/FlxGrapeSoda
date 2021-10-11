import flixel.FlxG;
import flixel.FlxState;

class BaseState extends FlxState
{
	override public function create()
	{
		FlxG.camera.pixelPerfectRender = true;
		super.create();
	}

	override public function update(elapsed:Float)
	{
		Input.update();
		super.update(elapsed);
	}
}
