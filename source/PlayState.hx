package;

import Money.Style;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
#if desktop
import Discord.State;
#end

typedef LevelData =
{
	var map:String;
	var backColor:String;
	var parallax:String;
	var parallaxColor:String;
	var lineHeight:Int;
	var clouds:Bool;
	var music:String;
	var player:String;
}

class PlayState extends FlxState
{
	public static var LEVEL:Int = 1;
	public static var MONEY:Int = 0;
	public static var TIME:Float = 0;
	public static var DEMO_END:Bool = false;

	// player variables
	var player:Player;
	var checkpoint:FlxPoint;

	// map variables
	var walls:FlxTilemap;
	var coins:FlxTypedGroup<Money>;
	var breakBlocks:FlxTypedGroup<BreakBlock>;
	var pickyEnemy:FlxTypedGroup<Enemy>;
	var flag:Flag;
	var scenario:FlxGroup;

	// misc
	var offLimits:Bool = false;
	var hud:HUD;
	var finished:Bool = false;
	var tutorial:FlxTilemap;

	#if (desktop && cpp)
	// discord
	public static var discordTime:Float;
	public static var discordPlayer:String;
	#end

	// Functions!
	function placeEntities(entity:EntityData)
	{
		switch (entity.name)
		{
			case "Player":
				player.setPosition(entity.x, entity.y);
				checkpoint = new FlxPoint(entity.x, entity.y);
			case "Coin":
				coins.add(new Money(entity.x, entity.y));
			case "Dollar":
				coins.add(new Money(entity.x, entity.y, Style.Dollar));
			case "Flag":
				flag.setPosition(entity.x, entity.y);
			case "BreakWall":
				breakBlocks.add(new BreakBlock(entity.x, entity.y));
			case "Enemy":
				pickyEnemy.add(new Enemy(entity.x, entity.y));
		}
	}

	function respawnPlayer(timer:FlxTimer)
	{
		FlxFlicker.flicker(player);
		player.setPosition(checkpoint.x, checkpoint.y);
		player.canMove = true;
		offLimits = false;
	}

	function punchEvent()
	{
		var playerDirection = player.facing == FlxObject.RIGHT ? 8 : -8;
		var punchRay:FlxPoint = new FlxPoint(player.x + playerDirection, player.y);
		breakBlocks.forEachAlive((block) ->
		{
			if (punchRay.inRect(block.getHitbox()))
				new FlxTimer().start(.25, (timer:FlxTimer) -> block.hurt(1));
		});
		pickyEnemy.forEachAlive((picky) ->
		{
			if (punchRay.inRect(picky.getHitbox()))
				picky.kill();
		});
	}

	function playerTouchCoin(player:Player, coin:Money)
	{
		if (player.alive && player.exists && coin.alive && coin.exists)
			coin.kill();
	}

	function playerHitEnemy(player:Player, picky:Enemy)
	{
		if (player.alive && picky.alive)
		{
			if (picky.isTouching(FlxObject.UP))
			{
				player.velocity.y = -100;
				picky.kill();
			}
		}
	}

	function finishLevel(player:Player, flag:Flag)
	{
		player.canMove = false;
		player.velocity.x = Player.SPEED / 2;
		player.facing = FlxObject.RIGHT;

		FlxG.camera.fade(FlxColor.BLACK, 1.5, false, () ->
		{
			trace('Level $LEVEL finished!');
			FlxG.switchState(new ShopState());
		});
	}

	// FlxState functions
	override public function create()
	{
		super.create();
		var uiCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		uiCamera.bgColor = FlxColor.TRANSPARENT;

		var level:LevelData = null;
		scenario = new FlxGroup();

		if (!DEMO_END)
		{
			level = Json.parse(Assets.getText(Paths.getLevel(LEVEL)));
			trace('Level $LEVEL: $level');

			var parallaxName:String = level.parallax;
			var parallax = new BackParallax(Paths.getImage('parallax/$parallaxName'), level.lineHeight, FlxColor.fromString(level.parallaxColor),
				level.clouds);
			add(parallax);

			FlxG.sound.playMusic(Paths.getMusic(level.music));
		}

		// preparar el nivel
		var map = new FlxOgmo3Loader(Paths.getOgmoData(), Paths.getMap(!DEMO_END ? level.map : "demoEnd"));
		this.bgColor = !DEMO_END ? FlxColor.fromString(level.backColor) : 0xFF111111;

		var backWalls = map.loadTilemap(Paths.getImage("legacy/backTileMap"), "BackBlocks");
		backWalls.follow();
		backWalls.setTileProperties(0, FlxObject.NONE);
		add(backWalls);

		walls = map.loadTilemap(Paths.getImage("legacy/tileMap"), "Blocks");
		walls.follow();
		walls.setTileProperties(0, FlxObject.NONE);
		walls.setTileProperties(1, FlxObject.ANY);
		scenario.add(walls);

		var shop = map.loadTilemap(Paths.getImage("shop"), "Shop");
		shop.follow();
		shop.setTileProperties(0, FlxObject.NONE);
		add(shop);

		#if !android
		var keysPath:String = Paths.getImage("keys");
		#if desktop
		if (FlxG.gamepads.lastActive != null)
			keysPath = Paths.getImage("keysGamepad");
		#end
		tutorial = map.loadTilemap(keysPath, "Keys");
		tutorial.follow();
		tutorial.setTileProperties(0, FlxObject.NONE);
		add(tutorial);
		FlxTween.num(tutorial.y, tutorial.y + 2, .5, {type: PINGPONG}, (v:Float) -> tutorial.y = v);
		#end

		if (!DEMO_END)
		{
			flag = new Flag();
			add(flag);
		}

		// Entities
		coins = new FlxTypedGroup<Money>();
		breakBlocks = new FlxTypedGroup<BreakBlock>();
		pickyEnemy = new FlxTypedGroup<Enemy>();
		player = new Player();
		player.punchCallback = punchEvent;

		// Mostrar el nivel
		scenario.add(breakBlocks);
		add(scenario);

		add(coins);
		add(pickyEnemy);
		add(player);

		map.loadEntities(placeEntities, "Entities");

		if (DEMO_END)
		{
			var sorry = new FlxBitmapText(Fonts.DEFAULT);
			sorry.setPosition(0, 35);
			sorry.text = "Sorry, but you\nwon't be able to\nhave it in this\nversion";
			sorry.alignment = CENTER;
			sorry.screenCenter(X);
			add(sorry);

			var grapeSoda = new FlxSprite(FlxG.width - 30, 95);
			grapeSoda.loadGraphic(Paths.getImage("items/grapesoda"));
			add(grapeSoda);
			FlxTween.num(grapeSoda.y, grapeSoda.y + 3, .5, {type: PINGPONG}, (v:Float) -> grapeSoda.y = v);
		}

		#if android
		var pad = new AndroidPad();
		add(pad);
		#end

		// preparar el juego
		FlxG.camera.follow(player, PLATFORMER, 1);

		hud = new HUD();
		add(hud);

		#if (cpp && desktop)
		if (!DEMO_END)
		{
			discordTime = Date.now().getTime();
			discordPlayer = level.player;
			Discord.changePresence(State.Level, discordPlayer, discordTime);
		}
		else
			Discord.changePresence(State.DemoEnd);
		#end

		FlxG.cameras.add(uiCamera, false);
		hud.cameras = [uiCamera];
		#if android
		pad.cameras = [uiCamera];
		#end
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		Input.update();

		FlxG.collide(player, scenario);

		if (player.x < 0)
			player.x = 0;

		if (!DEMO_END)
		{
			FlxG.collide(pickyEnemy, scenario);
			FlxG.collide(player, pickyEnemy, playerHitEnemy);
			FlxG.overlap(player, coins, playerTouchCoin);

			if (!finished)
				FlxG.overlap(player, flag, finishLevel);

			if (player.y > walls.height && !offLimits)
			{
				FlxG.camera.shake(.01, .25);
				player.canMove = false;
				new FlxTimer().start(1, respawnPlayer);
				offLimits = true;
			}

			TIME += elapsed;
		}
		else
		{
			if (player.x > FlxG.width / 2)
				player.x = FlxG.width / 2;
		}

		#if desktop
		if (FlxG.keys.justPressed.F4)
			FlxG.fullscreen = !FlxG.fullscreen;
		#end

		if (Input.PAUSE || Input.PAUSE_ALT)
			openSubState(new Pause());

		#if (debug && desktop)
		if (FlxG.keys.justPressed.L)
			finishLevel(player, flag);

		if (FlxG.keys.justPressed.PAGEUP)
			FlxG.camera.zoom += .1;

		if (FlxG.keys.justPressed.PAGEDOWN)
			FlxG.camera.zoom -= .1;
		#end
	}
}
