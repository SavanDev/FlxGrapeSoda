package misc;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class FadeBoy extends FlxSprite
{
	public var hasFadeIn(get, null):Bool;
	public var hasFadeOut(get, null):Bool;
	public var callbackOut:Void->Void;
	public var callbackIn:Void->Void;

	public function new(_color:FlxColor = FlxColor.BLACK, _fadeIn:Bool = true, ?_callbackOut:Void->Void, ?_callbackIn:Void->Void)
	{
		super();
		#if android
		var fadePath = Paths.getImage("misc/fadeAndroid");
		#else
		var fadePath = Paths.getImage("misc/fadePC");
		#end
		loadGraphic(fadePath, true, FlxG.width, FlxG.height);

		animation.add("fadeIn", [0, 1, 2, 3, 4], 5, false);
		animation.add("fadeOut", [4, 3, 2, 1, 0], 5, false);

		animation.finishCallback = (name:String) ->
		{
			if (name == "fadeOut" && callbackOut != null)
				callbackOut();
			else if (callbackIn != null)
				callbackIn();
		}

		if (_callbackOut != null)
			callbackOut = _callbackOut;

		if (_callbackIn != null)
			callbackIn = _callbackIn;

		if (_fadeIn)
			animation.play("fadeIn");
		else
			animation.frameIndex = 4;

		color = _color;
	}

	public function fadeIn(?_color:FlxColor)
	{
		if (_color != null)
			color = _color;

		animation.play("fadeIn");
	}

	public function fadeOut(?_color:FlxColor)
	{
		if (_color != null)
			color = _color;

		animation.play("fadeOut");
	}

	function get_hasFadeIn():Bool
	{
		return animation.finished && animation.name == "fadeIn" ? false : true;
	}

	function get_hasFadeOut():Bool
	{
		return animation.finished && animation.name == "fadeOut" ? false : true;
	}
}
