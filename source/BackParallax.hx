package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;

class BackParallax extends FlxGroup
{
	public var y(get, set):Int;

	var clouds:FlxBackdrop;
	var parallaxRelleno:FlxSprite;
	var parallax:FlxBackdrop;
	var lineaHorizonte:Int;
	var colorFondo:FlxColor;

	public function new(backImg:FlxGraphicAsset, horizonte:Int = 65, ?color:FlxColor, clouds:Bool = false)
	{
		super();
		lineaHorizonte = horizonte;

		parallax = new FlxBackdrop(backImg, .5, 1, true, false);
		parallax.y = horizonte;

		if (color != null)
		{
			colorFondo = color;
			parallaxRelleno = new FlxSprite(0, horizonte + (parallax.height / 1.5));
			parallaxRelleno.makeGraphic(Game.WIDTH, Std.int((Game.HEIGHT * 1.25) - parallaxRelleno.y), color);
			parallaxRelleno.scrollFactor.set(0, 1);
		}

		if (clouds)
		{
			this.clouds = new FlxBackdrop(Paths.getImage("parallax/nubes"), .25, 1, true, false);
			this.clouds.y = horizonte - 45;
		}

		if (this.clouds != null)
			add(this.clouds);
		if (parallaxRelleno != null)
			add(parallaxRelleno);
		add(parallax);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (clouds != null)
			clouds.x += elapsed * 2;
	}

	function cambiarHorizonte()
	{
		parallax.y = lineaHorizonte;

		if (parallaxRelleno != null)
		{
			parallaxRelleno.y = lineaHorizonte + (parallax.height / 1.5);
			parallaxRelleno.makeGraphic(Game.WIDTH, Std.int(Game.HEIGHT - parallaxRelleno.y), colorFondo);
		}

		if (clouds != null)
			clouds.y = lineaHorizonte - 45;
	}

	function get_y():Int
	{
		return lineaHorizonte;
	}

	function set_y(value:Int):Int
	{
		lineaHorizonte = value;
		cambiarHorizonte();
		return lineaHorizonte;
	}
}
