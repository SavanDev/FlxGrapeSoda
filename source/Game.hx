import flixel.FlxG;

class Game
{
	public static inline var PIXEL_PERFECT:Bool = false;
	public static inline var TILE_SIZE:Int = 12;
	public static inline var MAX_MULTIPLIER_WIDTH:Int = 6;

	public static inline var MAP_WIDTH:Int = 21;
	public static inline var MAP_HEIGHT:Int = 12;

	public static inline var WIDTH:Int = TILE_SIZE * MAP_WIDTH;
	public static inline var HEIGHT:Int = TILE_SIZE * MAP_HEIGHT;

	public static inline var MAX_LIVES:Int = 3;

	public static function initialize()
	{
		Fonts.loadBitmapFonts();

		#if !mobile
		FlxG.mouse.visible = false;
		#end

		#if desktop
		FlxG.save.bind("settings");

		if (FlxG.save.data.fullScreen == null)
			FlxG.save.data.fullScreen = false;
		else
			FlxG.fullscreen = FlxG.save.data.fullScreen;

		if (FlxG.save.data.soundsEnabled == null)
			FlxG.save.data.soundsEnabled = true;
		else
			FlxG.sound.muted = FlxG.save.data.soundsEnabled;

		if (FlxG.save.data.detectGamepad == null)
			FlxG.save.data.detectGamepad = true;
		else
			Input.detectGamepad = FlxG.save.data.detectGamepad;
		#end
	}
}
