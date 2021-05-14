package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxBitmapText;
import flixel.util.FlxTimer;

class SavanLogo extends FlxState
{
	override public function create()
	{
		super.create();
		FlxG.camera.zoom = 2;

		FlxG.camera.fade(1, true, () ->
		{
			new FlxTimer().start(1.5, (timer:FlxTimer) ->
			{
				FlxG.camera.fade(1, () ->
				{
					FlxG.switchState(new MenuState());
				});
			});
		});

		var logo = new FlxSprite();
		logo.loadGraphic(Paths.getImage("SDPixel"));
		logo.screenCenter();
		logo.y -= 5;
		add(logo);

		var logoText = new FlxBitmapText(Fonts.PF_ARMA_FIVE_16);
		logoText.text = "SavanDev";
		logoText.screenCenter();
		logoText.y += 20;
		add(logoText);
	}
}
