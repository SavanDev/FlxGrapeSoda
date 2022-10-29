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
		return 'assets/music/$file.ogg';
		#end
	}

	static public function getLevel(number:Int)
	{
		if (number == -1)
			return 'assets/data/levels/levelTest.json';
		else
			return 'assets/data/levels/level$number.json';
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
