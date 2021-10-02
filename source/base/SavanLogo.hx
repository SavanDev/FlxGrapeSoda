package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxBitmapText;
import flixel.util.FlxTimer;

class SavanLogo extends BaseState
{
	var logo:FlxSprite;
	var logoText:FlxBitmapText;

	override public function create()
	{
		super.create();
		Fonts.loadBitmapFonts();
		FlxG.camera.zoom = 2;

		FlxG.camera.fade(1, true, () ->
		{
			new FlxTimer().start(1.5, (timer:FlxTimer) ->
			{
				FlxG.camera.fade(1, () -> {
					#if nightly
					nightlyText();
					#else
					FlxG.switchState(new MenuState());
					#end
				});
			});
		});

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

		#if !mobile
		FlxG.mouse.visible = false;
		#end

		#if desktop
		FlxG.save.bind("settings");

		if (FlxG.save.data.fullScreen == null)
			FlxG.save.data.fullScreen = false;
		else
			FlxG.fullscreen = FlxG.save.data.fullScreen;
		#end
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

		FlxG.camera.fade(1, true, () ->
		{
			new FlxTimer().start(4, (_) ->
			{
				FlxG.camera.fade(1, () -> FlxG.switchState(new MenuState()));
			});
		});
	}
}
