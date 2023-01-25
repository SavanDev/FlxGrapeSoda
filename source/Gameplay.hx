import objects.Player;
import util.Timer;

typedef LevelData =
{
	var layers:Array<String>;
	var entities:String;
	var player:Int;
	var background:
		{
			type:Int,
			clouds:Bool,
			redValue:Int,
			greenValue:Int,
			blueValue:Int
		};
}

typedef MinimalLevelData =
{
	var player:String;
	var cutscene:String;
}

class Gameplay
{
	public static var LEVEL:Int = 0;
	public static var WORLD:Int = 1;

	public static var MONEY:Int = 0;
	public static var HUD:HUD;

	public static var GRAVITY:Float = 300;

	public static function resetGlobalVariables()
	{
		MONEY = 0;
		Timer.restart();
		LEVEL = Game.INITIAL_LEVEL;
		Player.LIVES = Game.MAX_LIVES;
	}
}
