package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.addons.tile.FlxTilemapExt;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import objects.BreakBlock;
import objects.Enemy;
import objects.Flag;
import objects.Money;
import objects.Player;
import states.CharacterState;
import util.Timer;
#if desktop
import Discord.State;
#end
#if mobile
import mobile.AndroidPad;
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

class PlayState extends BaseState
{
	public static var LEVEL:Int = 1;
	public static var MONEY:Int = 0;
	public static var DEMO_END:Bool = false;
	public static var ENEMIES_DEAD:Int = 0;
	public static var HUD:HUD;

	// player variables
	var player:Player;
	var checkpoint:FlxPoint;

	// map variables
	var walls:FlxTilemapExt;
	var coins:FlxTypedGroup<Money>;
	var breakBlocks:FlxTypedGroup<BreakBlock>;
	var pickyEnemy:FlxTypedGroup<Enemy>;
	var flag:Flag;
	var scenario:FlxGroup;

	// misc
	var offLimits:Bool = false;
	var finished:Bool = false;
	var tutorial:FlxTilemapExt;

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
		if (player.alive)
		{
			player.setPosition(checkpoint.x, checkpoint.y);
			player.canMove = true;
			offLimits = false;
		}
	}

	function punchEvent()
	{
		var playerX = (player.facing == FlxObject.LEFT) ? player.x - 6 : player.x;
		var playerWidth = (player.facing == FlxObject.RIGHT) ? player.width + 6 : player.width;
		var punchRay:FlxRect = new FlxRect(playerX, player.y, playerWidth, player.height);
		breakBlocks.forEachAlive((block) ->
		{
			if (punchRay.overlaps(block.getHitbox()))
				new FlxTimer().start(.25, (timer:FlxTimer) -> block.hurt(1));
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
			else
			{
				trace("Player HIT!");
				player.hurt(1);
			}
		}
	}

	function finishLevel(player:Player, flag:Flag)
	{
		FlxG.sound.play(Paths.getSound("finish"));
		Timer.stop();
		player.canMove = false;
		player.facing = FlxObject.RIGHT;

		FlxG.camera.fade(FlxColor.BLACK, 1.5, false, () ->
		{
			trace('Level $LEVEL finished!');
			FlxG.switchState(new ShopState());
		});

		finished = true;
	}

	// FlxState functions
	override public function create()
	{
		super.create();

		HUD = new HUD();
		add(HUD);

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

			Timer.start(HUD);
		}

		// preparar el nivel
		var map = new FlxOgmo3Loader(Paths.getOgmoData(), Paths.getMap(!DEMO_END ? level.map : "demoEnd"));
		FlxG.camera.bgColor = !DEMO_END ? FlxColor.fromString(level.backColor) : 0xFF111111;

		var backWalls = map.loadTilemapExt(Paths.getImage("legacy/backTileMap"), "BackBlocks");
		backWalls.follow();
		backWalls.setTileProperties(0, FlxObject.NONE);
		add(backWalls);

		walls = map.loadTilemapExt(Paths.getImage("legacy/tileMap"), "Blocks");
		walls.follow();
		walls.setTileProperties(0, FlxObject.NONE);
		walls.setTileProperties(1, FlxObject.ANY);
		scenario.add(walls);

		var shop = map.loadTilemapExt(Paths.getImage("shop"), "Shop");
		shop.follow();
		shop.setTileProperties(0, FlxObject.NONE);
		add(shop);

		#if !mobile
		var keysPath:String = Paths.getImage("keys");
		#if desktop
		if (Input.isGamepadConnected)
			keysPath = Paths.getImage("keysGamepad");
		#end
		tutorial = map.loadTilemapExt(keysPath, "Keys");
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
		add(player);
		add(pickyEnemy);

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

		#if mobile
		var pad = new AndroidPad();
		add(pad);
		#end

		// preparar el juego
		FlxG.camera.follow(player, PLATFORMER, .1);

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

		HUD.cameras = [uiCamera];
		#if mobile
		pad.cameras = [uiCamera];
		#end
	}

	public function pleaseCollide(enemy:Enemy, other:FlxObject)
	{
		enemy.direction = enemy.justTouched(FlxObject.LEFT) ? 1 : -1;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxG.collide(player, scenario);

		if (player.x < 0)
			player.x = 0;

		if (!DEMO_END)
		{
			FlxG.collide(pickyEnemy, scenario, pleaseCollide);
			if (!player.invencible)
				FlxG.collide(player, pickyEnemy, playerHitEnemy);
			FlxG.overlap(player, coins, playerTouchCoin);

			if (!finished)
				FlxG.overlap(player, flag, finishLevel);
			else
				player.velocity.x = Player.SPEED / 2;

			if (player.y > walls.height && !offLimits)
			{
				FlxG.camera.shake(.01, .25);
				player.canMove = false;
				player.hurt(1);
				new FlxTimer().start(1, respawnPlayer);
				offLimits = true;
			}
		}
		else
		{
			if (player.x > FlxG.width / 2)
				player.x = FlxG.width / 2;
		}

		if (Input.PAUSE || Input.PAUSE_ALT)
		{
			Timer.stop();
			persistentUpdate = false;
			openSubState(new substates.Pause());
		}

		#if (debug && desktop)
		if (FlxG.keys.justPressed.L)
			finishLevel(player, flag);

		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new CharacterState());

		if (FlxG.keys.justPressed.PAGEUP)
			FlxG.camera.zoom += .1;

		if (FlxG.keys.justPressed.PAGEDOWN)
			FlxG.camera.zoom -= .1;
		#end

		if (player.health <= 0)
			openSubState(new substates.GameOver());
	}
}
