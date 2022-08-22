import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxColor;

class BaseState extends FlxState
{
	var uiCamera:FlxCamera;

	override public function create()
	{
		super.create();
		persistentDraw = persistentUpdate = true;

		var gameCamera = new FlxCamera();
		gameCamera.pixelPerfectRender = Game.PIXEL_PERFECT;
		FlxG.cameras.reset(gameCamera);

		uiCamera = new FlxCamera();
		uiCamera.bgColor = FlxColor.TRANSPARENT;
		uiCamera.pixelPerfectRender = Game.PIXEL_PERFECT;
		FlxG.cameras.add(uiCamera, false);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		Input.update();
	}
}
