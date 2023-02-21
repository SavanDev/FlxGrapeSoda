import openfl.media.Sound;
import sys.FileSystem;

class Paths
{
	static inline var OGMO_DATA:String = "maps";

	static public function getImage(file:String)
	{
		return 'assets/images/$file.png';
	}

	static public function getSound(file:String)
	{
		#if web
		return 'assets/sounds/$file.mp3';
		#else
		return 'assets/sounds/$file.wav';
		#end
	}

	static public function getMusic(file:String)
	{
		#if web
		return 'assets/music/$file.mp3';
		#else
		if (FileSystem.exists('maps/music/$file.ogg'))
			return Sound.fromFile('maps/music/$file.ogg');
		else if (FileSystem.exists('assets/music/$file.ogg'))
			return Sound.fromFile('assets/music/$file.ogg');
		else
			return Sound.fromFile('assets/music/50s-bit.ogg'); // Default music
		#end
	}

	static public function getLevel(number:Int)
	{
		return 'assets/data/levels/level$number.json';
	}

	static public function getCustomLevel(level:String)
	{
		return 'maps/$level.json';
	}

	static public function getMap(file:String)
	{
		return 'assets/data/maps/$file.json';
	}

	static public function getOgmoData()
	{
		return 'assets/data/$OGMO_DATA.ogmo';
	}
}
