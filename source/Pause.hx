package;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.input.gamepad.FlxGamepad;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class Pause extends FlxSubState
{
	var exited:Bool = false;
	var options:FlxBitmapText;
	var canInteract:Bool = false;

	override public function create()
	{
		super.create();

		var pauseText:FlxBitmapText = new FlxBitmapText(Fonts.DEFAULT_16);
		pauseText.text = "Paused!";
		pauseText.alignment = CENTER;
		pauseText.scrollFactor.set(0, 0);
		pauseText.screenCenter();
		pauseText.y -= 10;
		add(pauseText);

		options = new FlxBitmapText(Fonts.DEFAULT);
		#if android
		options.text = "Touch to continue\nBACK again to exit";
		#else
		options.text = "ENTER to continue\nESCAPE to exit";
		#end
		options.useTextColor = true;
		options.textColor = FlxColor.YELLOW;
		options.alignment = CENTER;
		options.scrollFactor.set(0, 0);
		options.screenCenter();
		options.y += 10;
		add(options);

		new FlxTimer().start(.5, (timer:FlxTimer) -> canInteract = true);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (canInteract)
		{
			var continueKey:Bool = false, exitKey:Bool = false;
			var continueAltKey:Bool = false, exitAltKey:Bool = false;

			#if desktop
			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
			if (gamepad != null)
			{
				continueAltKey = gamepad.justPressed.START;
				exitAltKey = gamepad.justPressed.A;
				options.text = "START to continue\nA/X to exit";
			}
			else
				options.text = "ENTER to continue\nESCAPE to exit";
			#end

			#if android
			var touch = FlxG.touches.getFirst();
			if (touch != null)
				continueKey = touch.justPressed;
			exitKey = FlxG.android.justPressed.BACK;
			#else
			continueKey = FlxG.keys.justPressed.ENTER;
			exitKey = FlxG.keys.justPressed.ESCAPE;
			#end

			if (continueKey || continueAltKey)
				close();

			if ((exitKey || exitAltKey) && !exited)
			{
				exited = true;
				FlxG.camera.fade(.5, function()
				{
					// TODO: Hasta que haya algún sistema de guardado
					PlayState.MONEY = 0;
					PlayState.TIME = 0;
					PlayState.LEVEL = 1;

					FlxG.switchState(new MenuState());
				});
			}
		}
	}
}
