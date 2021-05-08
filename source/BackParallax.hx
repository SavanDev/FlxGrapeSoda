import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;

class BackParallax extends FlxGroup
{
	var clouds:FlxBackdrop;
	var backColor:FlxSprite;
	var parallax1:FlxBackdrop;

	public function new(Back1:FlxGraphicAsset, lineHeight:Int = 65, ?Color:FlxColor = FlxColor.TRANSPARENT, Cloud:Bool = false)
	{
		super();
		if (Color != null)
		{
			backColor = new FlxSprite(0, lineHeight + 55);
			backColor.makeGraphic(FlxG.width, 32, Color);
			backColor.scrollFactor.set(0, 1);
			add(backColor);
		}
		parallax1 = new FlxBackdrop(Back1, 1, 1, true, false);
		parallax1.y = lineHeight;
		add(parallax1);

		if (Cloud)
		{
			clouds = new FlxBackdrop(Paths.getImage("parallax/nubes"), 1, 1, true, false);
			clouds.y = lineHeight - 45;
			add(clouds);
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (clouds != null)
			clouds.x += elapsed * 2;
	}
}
