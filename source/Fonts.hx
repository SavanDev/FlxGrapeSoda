import flixel.graphics.frames.FlxBitmapFont;
import lime.utils.Assets;

class Fonts
{
	public static var PF_ARMA_FIVE:FlxBitmapFont;
	public static var PF_ARMA_FIVE_16:FlxBitmapFont;
	public static var DEFAULT:FlxBitmapFont;
	public static var DEFAULT_16:FlxBitmapFont;
	public static var TOY:FlxBitmapFont;

	public static function loadBitmapFonts()
	{
		var font8 = Assets.getText("assets/fonts/PFArmaFive.fnt");
		var font16 = Assets.getText("assets/fonts/PFArmaFive16.fnt");
		var xml8 = Xml.parse(font8);
		var xml16 = Xml.parse(font16);
		PF_ARMA_FIVE = FlxBitmapFont.fromAngelCode("assets/fonts/PFArmaFive_0.png", xml8);
		PF_ARMA_FIVE_16 = FlxBitmapFont.fromAngelCode("assets/fonts/PFArmaFive16_0.png", xml16);

		font8 = Assets.getText("assets/fonts/Default.fnt");
		font16 = Assets.getText("assets/fonts/Default16.fnt");
		xml8 = Xml.parse(font8);
		xml16 = Xml.parse(font16);
		DEFAULT = FlxBitmapFont.fromAngelCode("assets/fonts/Default_0.png", xml8);
		DEFAULT_16 = FlxBitmapFont.fromAngelCode("assets/fonts/Default16_0.png", xml16);

		font8 = Assets.getText("assets/fonts/Toy.fnt");
		xml8 = Xml.parse(font8);
		TOY = FlxBitmapFont.fromAngelCode("assets/fonts/Toy_0.png", xml8);

		trace("Bitmap fonts loaded!");
	}
}
