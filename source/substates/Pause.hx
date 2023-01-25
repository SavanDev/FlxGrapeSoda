package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;
import objects.Player;
import util.Timer;

class Pause extends FlxSubState
{
	var exited:Bool = false;
	var options:FlxBitmapText;

	override public function create()
	{
		super.create();

		// Establece la cámara por defecto de la pausa en "uiCamera"
		this.cameras = [FlxG.cameras.list[1]];

		// REVIEW: Con esto se arregla el problema del fondo al hacer zoom, pero tendré que buscar como hacerlo correctamente
		var background:FlxSprite = new FlxSprite(0, 0);
		background.makeGraphic(FlxG.width, FlxG.height, 0x99000000);
		add(background);

		var pauseText:FlxBitmapText = new FlxBitmapText(Fonts.DEFAULT_16);
		pauseText.text = "Paused!";
		pauseText.alignment = CENTER;
		pauseText.scrollFactor.set(0, 0);
		pauseText.screenCenter();
		pauseText.y -= 10;
		add(pauseText);

		options = new FlxBitmapText(Fonts.DEFAULT);
		#if mobile
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
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		Input.update();

		#if desktop
		if (Input.isGamepadConnected)
		{
			options.text = "A to continue\nBACK to exit";
			options.screenCenter(X);
		}
		else
		{
			options.text = "ENTER to continue\nESCAPE to exit";
			options.screenCenter(X);
		}
		#end

		if (Input.SELECT || Input.SELECT_ALT)
		{
			Timer.start();
			close();
		}

		if ((Input.BACK || Input.BACK_ALT) && !exited)
		{
			exited = true;
			FlxG.camera.fade(.5, () ->
			{
				// TODO: Hasta que haya algún sistema de guardado
				Gameplay.resetGlobalVariables();

				FlxG.switchState(new MenuState());
			});
		}
	}
}
