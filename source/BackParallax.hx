import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup;

class BackParallax extends FlxGroup
{
	var clouds:FlxBackdrop;

	// Overworld
	var overworldBack:FlxSprite;
	var overworld:FlxBackdrop;

	// City
	var city1:FlxBackdrop;
	var city2:FlxBackdrop;

	public function new(type:Int = 0, showClouds:Bool = true)
	{
		super();
		city2 = new FlxBackdrop(Paths.getImage('parallax/city2'), .1, 0, true, false);
		city2.setGraphicSize(Std.int(city2.width * 2));
		city2.y = Game.HEIGHT - city2.height;
		add(city2);

		clouds = new FlxBackdrop(Paths.getImage("parallax/clouds"), .25, 0, true, false);
		clouds.y = 17;
		add(clouds);

		overworldBack = new FlxSprite();
		overworldBack.makeGraphic(Game.WIDTH, Std.int(Game.HEIGHT - overworldBack.y), 0xFF005100);
		overworldBack.scrollFactor.set();
		add(overworldBack);

		overworld = new FlxBackdrop(Paths.getImage('parallax/mountain'), .5, 0, true, false);
		overworld.y = 65;
		overworldBack.y = overworld.y + 52;
		add(overworld);

		city1 = new FlxBackdrop(Paths.getImage('parallax/city1'), .3, 0, true, false);
		city1.setGraphicSize(Std.int(city1.width * 2));
		city1.y = Game.HEIGHT - city1.height;
		add(city1);

		setBackgroundType(type);

		if (!showClouds)
			clouds.visible = false;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (clouds != null)
			clouds.x += elapsed * 2;
	}

	public function setBackgroundType(type:Int)
	{
		switch (type)
		{
			case 0:
				overworld.visible = overworldBack.visible = true;
				city1.visible = city2.visible = false;
			case 1:
				overworld.visible = overworldBack.visible = false;
				city1.visible = city2.visible = true;
		}
	}

	public function toggleClouds()
	{
		clouds.visible = !clouds.visible;
	}
}
