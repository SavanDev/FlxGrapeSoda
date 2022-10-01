package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import states.ComicState;

class SavanLogo extends BaseState
{
	static inline var WAIT_TIME:Int = 3;

	override public function create()
	{
		super.create();
		Game.initialize();
		FlxG.camera.zoom = 2;

		var letter = new FlxSprite(Paths.getImage("logo/SDPixel2"));
		letter.screenCenter();
		letter.y -= 5;

		var logo = new FlxSprite(letter.x, letter.y, Paths.getImage("logo/SDPixel"));
		var sdText = new FlxBitmapText(Fonts.DEFAULT);
		sdText.text = "SavanDev";
		sdText.screenCenter();
		sdText.y += 20;

		add(logo);
		add(letter);
		add(sdText);

		letter.visible = false;
		logo.alpha = 0;
		sdText.alpha = 0;

		new FlxTimer().start(.5, (_) ->
		{
			letter.visible = true;
			new FlxTimer().start(1, (_) ->
			{
				FlxTween.num(0, 1, WAIT_TIME - 2, {onComplete: (_) -> new FlxTimer().start(2, nextScene)}, (v) -> logo.alpha = sdText.alpha = v);
			});
		});
	}

	function nextScene(timer:FlxTimer)
	{
		trace("Let's go!");
		// FlxG.switchState(new MenuState());
		FlxG.switchState(new ComicState("intro", MenuState));
	}
}
