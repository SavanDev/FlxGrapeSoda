package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxBitmapText;
import flixel.util.FlxTimer;
import objects.Player;
import util.Timer;

class GameOver extends FlxSubState
{
	override public function create()
	{
		super.create();
		FlxG.sound.music.stop();

		// Establece la cámara por defecto de la pausa en "uiCamera"
		this.cameras = [FlxG.cameras.list[1]];

		// REVIEW: Con esto se arregla el problema del fondo al hacer zoom, pero tendré que buscar como hacerlo correctamente
		var background:FlxSprite = new FlxSprite(0, 0);
		background.makeGraphic(FlxG.width, FlxG.height, 0x99000000);
		add(background);

		var pauseText:FlxBitmapText = new FlxBitmapText(Fonts.DEFAULT_16);
		pauseText.text = "GAME OVER!";
		pauseText.alignment = CENTER;
		pauseText.scrollFactor.set(0, 0);
		pauseText.screenCenter();
		pauseText.y -= 10;
		add(pauseText);

		new FlxTimer().start(5, (_) ->
		{
			// TODO: Hasta que haya algún sistema de guardado
			Gameplay.resetGlobalVariables();

			FlxG.switchState(new MenuState());
		});
	}
}
