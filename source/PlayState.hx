package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;
import flixel.tile.FlxTilemap;
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
import substates.GameOver;
import substates.Pause;
import types.Entity;
import util.Timer;
#if desktop
import Discord.State;
#end
#if mobile
import mobile.AndroidPad;
#end

typedef LevelData =
{
	var layers:Array<String>;
	var entities:String;
	var player:Int;
	var background:
		{
			type:Int,
			clouds:Bool,
			redValue:Int,
			greenValue:Int,
			blueValue:Int
		};
}

class PlayState extends BaseState
{
	public static var LEVEL:Int = -1;
	public static var MONEY:Int = 0;
	public static var HUD:HUD;

	// player variables
	var player:Player;
	var checkpoint:FlxPoint;

	// map variables
	var groundMap:FlxTilemap;
	var staticObjectsMap:FlxTilemap;

	var coins:FlxTypedGroup<Money>;
	var pickyEnemy:FlxTypedGroup<Enemy>;
	var flag:Flag;

	// misc
	var offLimits:Bool = false;
	var finished:Bool = false;
	var tutorial:FlxTilemap;

	#if (desktop && cpp)
	// discord
	public static var discordTime:Float;
	public static var discordPlayer:Int;
	#end

	// Functions!
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

	function finishLevel()
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

		var level:LevelData = Json.parse(Assets.getText(Paths.getLevel(LEVEL)));
		trace('Level $LEVEL: $level');

		var parallax = new BackParallax(level.background.type, level.background.clouds);
		add(parallax);

		// TODO: Music level in JSON
		FlxG.sound.playMusic(Paths.getMusic("50s-bit"));

		Timer.start(HUD);

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

		#if !mobile
		var keysPath:String = Paths.getImage("keys");
		#if desktop
		if (Input.isGamepadConnected)
			keysPath = Paths.getImage("keysGamepad");
		#end
		/*tutorial = map.loadTilemap(keysPath, "Keys");
			add(tutorial);
			FlxTween.num(tutorial.y, tutorial.y + 2, .5, {type: PINGPONG}, (v:Float) -> tutorial.y = v); */
		#end

		// Entities
		coins = new FlxTypedGroup<Money>();
		pickyEnemy = new FlxTypedGroup<Enemy>();
		flag = new Flag();
		player = new Player();

		initializeEntities(Json.parse(level.entities));

		// Mostrar el nivel
		add(flag);
		add(coins);
		add(player);
		add(pickyEnemy);

		/*if (DEMO_END)
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
		}*/

		#if mobile
		var pad = new AndroidPad();
		add(pad);
		#end

		// preparar el juego
		FlxG.camera.follow(player, PLATFORMER, .1);

		#if (cpp && desktop)
		discordTime = Date.now().getTime();
		discordPlayer = level.player;
		Discord.changePresence(State.Level, discordPlayer, discordTime);
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

		FlxG.collide(player, staticObjectsMap);
		FlxG.collide(player, groundMap);

		if (player.x < 0)
			player.x = 0;

		FlxG.collide(pickyEnemy, staticObjectsMap, pleaseCollide);
		FlxG.collide(pickyEnemy, groundMap, pleaseCollide);

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
