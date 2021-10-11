package util;

import flixel.util.FlxTimer;

class Timer
{
	static var MINUTES:Int = 0;
	static var SECONDS:Int = 0;
	static var FTIMER:FlxTimer;

	static function counter(_hud:HUD)
	{
		SECONDS++;
		if (SECONDS >= 60)
		{
			SECONDS = 0;
			MINUTES++;
		}

		if (_hud != null)
			_hud.updateTimer(MINUTES, SECONDS);
	}

	static public function getMinutes():Int
	{
		return MINUTES;
	}

	static public function getSeconds():Int
	{
		return SECONDS;
	}

	static public function start(_hud:HUD = null)
	{
		if (FTIMER == null || FTIMER.manager != null)
			FTIMER = new FlxTimer().start(1, (tmr) -> counter(_hud), 0);
		else
			FTIMER.active = true;
	}

	static public function stop()
	{
		FTIMER.active = false;
	}

	static public function restart()
	{
		MINUTES = SECONDS = 0;
	}
}
