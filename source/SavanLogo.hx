package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import misc.FadeBoy;

class SavanLogo extends GameBaseState
{
	var logo:FlxSprite;
	var logoText:FlxBitmapText;
	var fadeBoy:FadeBoy;

	override public function create()
	{
		super.create();
		Fonts.loadBitmapFonts();
		FlxG.camera.zoom = 2;

		logo = new FlxSprite();
		logo.loadGraphic(Paths.getImage("SDPixel"));
		logo.screenCenter();
		logo.y -= 5;
		add(logo);

		logoText = new FlxBitmapText(Fonts.DEFAULT);
		logoText.text = "SavanDev";
		logoText.screenCenter();
		logoText.y += 20;
		add(logoText);

		fadeBoy = new FadeBoy(FlxColor.BLACK, true, onFadeOut, onFadeIn);
		add(fadeBoy);

		#if !android
		FlxG.mouse.visible = false;
		#end
	}

	function onFadeOut()
	{
		#if nightly
		nightlyText();
		#else
		FlxG.switchState(new MenuState());
		#end
	}

	function onFadeIn()
	{
		new FlxTimer().start(1.5, (timer:FlxTimer) -> fadeBoy.fadeOut());
	}

	function nightlyText()
	{
		remove(logo);
		remove(logoText);

		FlxG.camera.zoom = 1;

		var warningNightly = new FlxBitmapText(Fonts.TOY);
		warningNightly.autoSize = false;
		warningNightly.fieldWidth = FlxG.width - 25;
		warningNightly.text = "WARNING:\nThe game is in an early stage of its development and many items may not yet be implemented/completed.";
		warningNightly.alignment = CENTER;
		warningNightly.screenCenter();
		add(warningNightly);

		fadeBoy.fadeIn();
		fadeBoy.callbackIn = () -> new FlxTimer().start(4, (_) -> fadeBoy.fadeOut());
		fadeBoy.callbackOut = () -> FlxG.switchState(new MenuState());
	}
}
