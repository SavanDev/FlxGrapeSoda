package;

#if desktop
import Discord.State;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.text.FlxBitmapText;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;

class DemoState extends FlxState
{
	var player:Player;
	var floor:FlxTilemap;
	var grapeSoda:FlxSprite;

	function placeEntities(entity:EntityData)
	{
		switch (entity.name)
		{
			case "Player":
				player.setPosition(entity.x, entity.y);
		}
	}

	override public function create()
	{
		super.create();
		bgColor = 0xFF111111;

		var map = new FlxOgmo3Loader(Paths.getOgmoData(), Paths.getMap("demoEnd"));
		floor = map.loadTilemap(Paths.getImage("tileMap"), "Blocks");
		floor.follow();
		floor.setTileProperties(0, FlxObject.NONE);
		floor.setTileProperties(1, FlxObject.ANY);
		add(floor);

		player = new Player();
		map.loadEntities(placeEntities, "Entities");
		add(player);

		var sorry = new FlxBitmapText(Fonts.DEFAULT);
		sorry.setPosition(0, 20);
		sorry.text = "Sorry, but you\nwon't be able to\nhave it in this\nversion";
		sorry.alignment = CENTER;
		sorry.screenCenter(X);
		add(sorry);

		grapeSoda = new FlxSprite(FlxG.width - 30, 95);
		grapeSoda.loadGraphic(Paths.getImage("items/grapesoda"));
		add(grapeSoda);
		FlxTween.num(grapeSoda.y, grapeSoda.y + 3, .5, {type: PINGPONG}, (v:Float) -> grapeSoda.y = v);

		#if android
		var pad = new AndroidPad();
		add(pad);
		#end

		FlxG.camera.follow(player, PLATFORMER, 1);

		#if (cpp && desktop)
		Discord.changePresence(State.DemoEnd);
		#end
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		Input.update();
		FlxG.collide(player, floor);

		if (player.x < 0)
			player.x = 0;

		if (player.x > FlxG.width / 2)
			player.x = FlxG.width / 2;

		#if desktop
		if (FlxG.keys.justPressed.F4)
			FlxG.fullscreen = !FlxG.fullscreen;
		#end

		if (Input.PAUSE || Input.PAUSE_ALT)
			openSubState(new Pause(0x99000000));
	}
}
