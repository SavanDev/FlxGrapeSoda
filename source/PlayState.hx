package;

import Money.Style;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
#if desktop
import Discord.State;
import flixel.input.gamepad.FlxGamepad;
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

	#if desktop
	var _gamepad:FlxGamepad;
	#end

	// player variables
	var player:Player;
	var checkpoint:FlxPoint;

	// map variables
	var map:FlxOgmo3Loader;
	var walls:FlxTilemap;
	var coins:FlxTypedGroup<Money>;
	var breakBlocks:FlxTypedGroup<BreakBlock>;
	var pickyEnemy:FlxTypedGroup<Enemy>;
	var flag:Flag;

	var scenario:FlxGroup;

	// misc
	#if android
	var pad:MobilePad;
	#end
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

	function playerTouchCoin(player:Player, coin:Money)
	{
		if (player.alive && player.exists && coin.alive && coin.exists)
			coin.kill();
	}

	function playerBreakBlock(player:Player, block:BreakBlock)
	{
		if (player.isPunching)
		{
			new FlxTimer().start(.25, (timer:FlxTimer) ->
			{
				block.hurt(1);
			});
		}
	}

	function playerHitEnemy(player:Player, picky:Enemy)
	{
		if (player.alive && picky.alive)
		{
			if (player.isPunching && (player.facing != picky.facing))
				picky.kill();
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

		scenario = new FlxGroup();

		var level:LevelData = Json.parse(Assets.getText(Paths.getLevel(LEVEL)));
		trace('Level $LEVEL: $level');

		this.bgColor = FlxColor.fromString(level.backColor);

		// preparar el nivel
		map = new FlxOgmo3Loader(Paths.getOgmoData(), Paths.getMap(level.map));

		var parallaxName:String = level.parallax;
		var parallax = new BackParallax(Paths.getImage('parallax/$parallaxName'), level.lineHeight, FlxColor.fromString(level.parallaxColor), level.clouds);
		add(parallax);

		var backWalls = map.loadTilemap(Paths.getImage("backTileMap"), "BackBlocks");
		backWalls.follow();
		backWalls.setTileProperties(0, FlxObject.NONE);
		add(backWalls);

		walls = map.loadTilemap(Paths.getImage("tileMap"), "Blocks");
		walls.follow();
		walls.setTileProperties(0, FlxObject.NONE);
		walls.setTileProperties(1, FlxObject.ANY);
		add(walls);

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

		flag = new Flag();
		add(flag);

		coins = new FlxTypedGroup<Money>();
		add(coins);

		breakBlocks = new FlxTypedGroup<BreakBlock>();
		add(breakBlocks);

		pickyEnemy = new FlxTypedGroup<Enemy>();
		add(pickyEnemy);

		player = new Player();
		add(player);

		map.loadEntities(placeEntities, "Entities");

		scenario.add(walls);
		scenario.add(pickyEnemy);
		scenario.add(breakBlocks);

		#if android
		pad = new MobilePad();
		player.mobilePad = pad;
		add(pad);
		#end

		// preparar el juego
		FlxG.camera.follow(player, PLATFORMER, 1);
		FlxG.sound.playMusic(Paths.getMusic(level.music));

		hud = new HUD();
		add(hud);

		#if (cpp && desktop)
		discordTime = Date.now().getTime();
		discordPlayer = level.player;
		Discord.changePresence(State.Level, discordPlayer, discordTime);
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
		var pauseKey:Bool = false, pauseAltKey:Bool = false;

		#if desktop
		_gamepad = FlxG.gamepads.lastActive;
		player.gamepad = _gamepad;
		if (_gamepad != null)
			pauseAltKey = _gamepad.justPressed.START;
		#end

		#if android
		pauseKey = FlxG.android.justPressed.BACK;
		#else
		pauseKey = FlxG.keys.justPressed.ENTER;
		#end

		FlxG.collide(player, walls);
		FlxG.collide(pickyEnemy, scenario);
		FlxG.collide(player, pickyEnemy, playerHitEnemy);
		FlxG.overlap(player, coins, playerTouchCoin);
		FlxG.collide(player, breakBlocks, playerBreakBlock);

		if (!finished)
			FlxG.overlap(player, flag, finishLevel);

		if (player.x < 0)
			player.x = 0;

		if (player.y > walls.height && !offLimits)
		{
			FlxG.camera.shake(.01, .25);
			player.canMove = false;
			new FlxTimer().start(1, respawnPlayer);
			offLimits = true;
		}

		TIME += elapsed;

		#if desktop
		if (FlxG.keys.justPressed.F4)
			FlxG.fullscreen = !FlxG.fullscreen;
		#end

		if (pauseKey || pauseAltKey)
			openSubState(new Pause(0x99000000));

		#if (debug && desktop)
		if (FlxG.keys.justPressed.L)
			finishLevel(player, flag);
		#end
	}
}
