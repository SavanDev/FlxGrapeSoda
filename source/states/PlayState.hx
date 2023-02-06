package states;

import Gameplay;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import objects.BreakableBlock;
import objects.Enemy;
import objects.Flag;
import objects.Money;
import objects.Player;
import objects.Sign;
import states.CharacterState;
import substates.GameOver;
import substates.Pause;
import sys.io.File;
import types.Entity;
import util.Timer;
#if mobile
import mobile.AndroidPad;
#end

class PlayState extends BaseState
{
	// player variables
	var player:Player;
	var checkpoint:FlxPoint;

	// map variables
	var groundMap:FlxTilemap;
	var staticObjectsMap:FlxTilemap;

	var coins:FlxTypedGroup<Money>;
	var breakableBlocks:FlxTypedGroup<BreakableBlock>;
	var pickyEnemy:FlxTypedGroup<Enemy>;
	var flag:Flag;
	var signs:FlxTypedGroup<Sign>;

	var breakableBlockSelected:BreakableBlock;
	var breakBlockCollision:Bool;

	var backgroundSign:FlxSprite;
	var signText:FlxBitmapText;
	var signUI:FlxSpriteGroup;

	// misc
	var offLimits:Bool = false;
	var finished:Bool = false;
	var tutorial:FlxTilemap;

	function initializeEntities(entities:Array<Entity>)
	{
		for (entity in entities)
		{
			switch (entity.type)
			{
				case 0:
					player.setPosition(entity.x, entity.y);
					checkpoint = new FlxPoint(entity.x, entity.y);
				case 1:
					pickyEnemy.add(new Enemy(entity.x, entity.y));
				case 2:
					coins.add(new Money(entity.x, entity.y));
				case 3:
					flag.setPosition(entity.x, entity.y);
				case 4:
					breakableBlocks.add(new BreakableBlock(entity.x, entity.y));
				case 5:
					signs.add(new Sign(entity.x, entity.y, entity.msg));
			}
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

	function playerTouchCoin(player:Player, coin:Money)
	{
		if (player.alive && player.exists && coin.alive && coin.exists)
			coin.kill();
	}

	function playerHitEnemy(player:Player, picky:Enemy)
	{
		if (player.alive && picky.alive)
		{
			if (picky.isTouching(UP))
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

	function finishLevel()
	{
		FlxG.sound.play(Paths.getSound("finish"));
		Timer.stop();
		player.canMove = false;
		player.facing = RIGHT;

		FlxG.camera.fade(FlxColor.BLACK, 1.5, false, () ->
		{
			trace('Level ${Gameplay.LEVEL} finished!');
			FlxG.switchState(new ShopState());
		});

		finished = true;
	}

	// FlxState functions
	override public function create()
	{
		super.create();

		Gameplay.HUD = new HUD();
		add(Gameplay.HUD);

		var level:LevelData = Json.parse(File.getContent(Gameplay.STORY_MODE ? Paths.getLevel(Gameplay.LEVEL) : Paths.getCustomLevel(Gameplay.LEVELNAME)));
		trace('Level ${Gameplay.LEVEL}: $level');

		var parallax = new BackParallax(level.background.type, level.background.clouds);
		add(parallax);

		var levelMusic = level.music != null ? Paths.getMusic(level.music) : Paths.getMusic("50s-bit");
		FlxG.sound.playMusic(levelMusic);

		Timer.start(Gameplay.HUD);

		// preparar el nivel
		FlxG.camera.bgColor = FlxColor.fromRGB(level.background.redValue, level.background.greenValue, level.background.blueValue);

		var maxWidth:Int = Game.WIDTH * Game.MAX_MULTIPLIER_WIDTH;
		var maxHeight:Int = Game.HEIGHT;
		var tileSize:Int = Game.TILE_SIZE;

		var backTiles = new FlxTilemap();
		backTiles.loadMapFromArray(Json.parse(level.layers[2]), maxWidth, maxHeight, Paths.getImage("tilemaps/backtiles"), tileSize, tileSize);
		add(backTiles);

		staticObjectsMap = new FlxTilemap();
		staticObjectsMap.loadMapFromArray(Json.parse(level.layers[1]), maxWidth, maxHeight, Paths.getImage("tilemaps/objects"), tileSize, tileSize);
		add(staticObjectsMap);

		groundMap = new FlxTilemap();
		groundMap.loadMapFromArray(Json.parse(level.layers[0]), maxWidth, maxHeight, Paths.getImage("tilemaps/grass"), tileSize, tileSize, FULL);
		add(groundMap);

		FlxG.camera.setScrollBoundsRect(0, 0, maxWidth, maxHeight, true);

		// Entities
		coins = new FlxTypedGroup<Money>();
		breakableBlocks = new FlxTypedGroup<BreakableBlock>();
		pickyEnemy = new FlxTypedGroup<Enemy>();
		flag = new Flag();
		signs = new FlxTypedGroup<Sign>();
		player = new Player();

		initializeEntities(Json.parse(level.entities));

		// Mostrar el nivel
		add(flag);
		add(coins);
		add(signs);
		add(pickyEnemy);
		add(player);
		add(breakableBlocks);

		#if mobile
		var pad = new AndroidPad();
		add(pad);
		#end

		// preparar el juego
		FlxG.camera.follow(player, PLATFORMER, .1);

		Gameplay.HUD.cameras = [uiCamera];
		#if mobile
		pad.cameras = [uiCamera];
		#end

		player.punchCallback = () ->
		{
			if (breakableBlockSelected != null)
				breakableBlockSelected.hurt(1);
		};

		signUI = new FlxSpriteGroup();
		signUI.scrollFactor.set();
		add(signUI);

		backgroundSign = new FlxSprite();
		backgroundSign.makeGraphic(FlxG.width, 20, 0xAA000000);
		backgroundSign.setPosition(0, FlxG.height / 2);
		signUI.add(backgroundSign);

		signText = new FlxBitmapText(Fonts.DEFAULT);
		signText.setPosition(5, backgroundSign.y + 5);
		signUI.add(signText);
	}

	function breakableBlockWithPlayer(player:Player, breakableBlock:BreakableBlock)
	{
		if (breakableBlockSelected == null)
			breakableBlockSelected = breakableBlock;
	}

	function signHandle(player:Player, sign:Sign)
	{
		signUI.visible = true;
		signText.text = sign.message;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxG.collide(player, staticObjectsMap);
		FlxG.collide(player, groundMap);
		breakBlockCollision = FlxG.collide(player, breakableBlocks, breakableBlockWithPlayer);

		if (!FlxG.overlap(player, signs, signHandle) && signUI.visible)
			signUI.visible = false;

		if (!breakBlockCollision && breakableBlockSelected != null)
			breakableBlockSelected = null;

		if (player.x < 0)
			player.x = 0;

		FlxG.collide(pickyEnemy, staticObjectsMap);
		FlxG.collide(pickyEnemy, groundMap);
		FlxG.collide(pickyEnemy, breakableBlocks);

		if (!player.invencible)
			FlxG.collide(player, pickyEnemy, playerHitEnemy);
		FlxG.overlap(player, coins, playerTouchCoin);

		if (!finished)
		{
			if (player.x >= flag.x)
				finishLevel();
		}
		else
			player.velocity.x = Player.SPEED / 2;

		if (player.y > groundMap.height && !offLimits)
		{
			FlxG.camera.shake(.01, .25);
			player.canMove = false;
			player.hurt(1);
			new FlxTimer().start(1, respawnPlayer);
			offLimits = true;
		}

		if (Input.PAUSE || Input.PAUSE_ALT)
		{
			Timer.stop();
			persistentUpdate = false;
			openSubState(new Pause());
		}

		#if (debug && desktop)
		if (FlxG.keys.justPressed.L)
			finishLevel();

		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new CharacterState());

		if (FlxG.keys.justPressed.PAGEUP)
			FlxG.camera.zoom += .1;

		if (FlxG.keys.justPressed.PAGEDOWN)
			FlxG.camera.zoom -= .1;
		#end

		if (player.health <= 0)
			openSubState(new GameOver());
	}
}
