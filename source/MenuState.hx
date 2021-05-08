package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.text.FlxBitmapText;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import lime.system.System;
#if desktop
import Discord.State;
import flixel.input.gamepad.FlxGamepad;
#end
#if android
import flixel.input.android.FlxAndroidKey;
#end

class MenuState extends FlxState
{
	var map:FlxOgmo3Loader;
	var tileMap:FlxTilemap;
	var player:Player;

	var logoText1:FlxBitmapText;
	var logoText2:FlxBitmapText;
	var logoSoda:FlxSprite;
	var playText:FlxBitmapText;
	var versionText:FlxBitmapText;
	var playTimer:FlxTimer;

	var LOGO_X = FlxG.width / 2 - 63;
	var LOGO_Y = 20;

	#if desktop
	var gamepad:FlxGamepad;
	#end

	function entitiesPos(entity:EntityData)
	{
		if (entity.name == "Player")
			player.setPosition(FlxG.width / 2, entity.y);
	}

	function playBlink(timer:FlxTimer)
	{
		playText.visible = !playText.visible;
	}

	function startGame()
	{
		playText.textColor = FlxColor.YELLOW;
		playTimer.time = .1;
		FlxG.sound.play(Paths.getSound("select"));
		player.velocity.x = Player.SPEED;
	}

	function showMenu()
	{
		// more kills!
		playText.kill();
		player.kill();
		var menu = new Menu(10, 70);
		menu.addEvent(0, () ->
		{
			menu.kill();
			FlxG.sound.play(Paths.getSound("select"));
			FlxG.camera.fade(0xFF111111, () -> FlxG.switchState(new ReadyState()));
		});
		menu.addEvent(1, () -> FlxG.openURL("https://ko-fi.com/savandev"));
		#if desktop
		menu.addEvent(2, () -> System.exit(0));
		#end
		add(menu);
	}

	override public function create()
	{
		super.create();

		#if android
		FlxG.android.preventDefaultKeys = [FlxAndroidKey.BACK];
		#end

		#if (desktop && cpp)
		if (!Discord.hasStarted)
		{
			Discord.init();
			Application.current.onExit.add((exitCode) ->
			{
				Discord.close();
			});
		}
		else
			Discord.changePresence(State.Title);
		#end

		// UI
		Fonts.loadBitmapFonts();
		// start!
		var startText:String;

		#if android
		startText = "Tap to start!";
		#else
		startText = "Press ENTER!";
		#end

		playText = new FlxBitmapText(Fonts.DEFAULT);
		playText.text = startText;
		playText.alignment = CENTER;
		playText.useTextColor = true;
		playText.setPosition(FlxG.width / 2 - (playText.getStringWidth(startText) / 2), 65);
		add(playText);

		playTimer = new FlxTimer().start(1, playBlink, 0);

		// logo
		logoText1 = new FlxBitmapText(Fonts.PF_ARMA_FIVE);
		logoText1.text = "Latin American needs...";
		logoText1.setPosition(LOGO_X, LOGO_Y);

		logoText2 = new FlxBitmapText(Fonts.PF_ARMA_FIVE_16);
		logoText2.text = "GRAPE SODA!";
		logoText2.setBorderStyle(OUTLINE, 0xFF5B315B);
		logoText2.setPosition(LOGO_X, LOGO_Y + 5);

		logoSoda = new FlxSprite(LOGO_X + 100, LOGO_Y);
		logoSoda.loadGraphic(Paths.getImage("items/grapesoda"), false, 12, 14);
		logoSoda.setGraphicSize(24, 28);
		logoSoda.updateHitbox();
		logoSoda.angle = -10;
		add(logoText1);
		add(logoText2);
		add(logoSoda);

		FlxTween.num(LOGO_Y, LOGO_Y + 3, .5, {type: PINGPONG}, (v:Float) ->
		{
			logoText1.y = v;
			logoText2.y = 5 + v;
			logoSoda.y = v;
		});

		// Escenario
		FlxG.camera.bgColor = 0xFF64A5FF;

		// fondo
		var parallax = new FlxBackdrop(Paths.getImage("parallax/mountain"), 1, 1, true, false);
		parallax.y = 65;
		add(parallax);

		// mini nivel
		map = new FlxOgmo3Loader(Paths.getOgmoData(), Paths.getMap("menuMap"));
		tileMap = map.loadTilemap(Paths.getImage("tileMap"), "Blocks");
		add(tileMap);
		player = new Player(0, 0, true);
		map.loadEntities(entitiesPos, "Entities");
		add(player);

		// musica
		if (FlxG.sound.music != null)
			FlxG.camera.fade(.5, true);
		FlxG.sound.playMusic(Paths.getMusic("effervesce"));

		// texto de la versión
		versionText = new FlxBitmapText();
		#if web
		versionText.text = 'Nightly version';
		#else
		versionText.text = 'v${Application.current.meta.get("version")}';
		#end
		versionText.alignment = RIGHT;
		versionText.setPosition(FlxG.width - versionText.getStringWidth(versionText.text) - 10, FlxG.height - 10);
		add(versionText);

		var kofi:FlxSprite = new FlxSprite(5, FlxG.height - 15);
		kofi.loadGraphic(Paths.getImage("kofi"));
		add(kofi);

		#if !FLX_NO_MOUSE
		FlxG.mouse.visible = false;
		#end

		// FIXME: Pequeño arreglo temporal. Luego voy a tener que estudiar un poco más el sistema de sonidos.
		FlxG.sound.defaultSoundGroup.volume = .5;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		#if desktop
		gamepad = FlxG.gamepads.lastActive;
		if (gamepad != null)
			playText.text = "Press START!";
		else
			playText.text = "Press ENTER!";
		#end

		if (playTimer.time != .1)
		{
			var startKey:Bool = false, startAltKey:Bool = false;

			#if android
			var touch = FlxG.touches.getFirst();
			if (touch != null)
				startKey = touch.justPressed;
			#else
			startKey = FlxG.keys.justPressed.ENTER;
			#end

			#if desktop
			if (gamepad != null)
				startAltKey = gamepad.pressed.START;
			#end

			if (startKey || startAltKey)
				startGame();
		}

		if (player.alive && !player.isOnScreen())
			showMenu();

		#if desktop
		if (FlxG.keys.justPressed.F4)
			FlxG.fullscreen = !FlxG.fullscreen;
		#end

		#if android
		if (FlxG.android.pressed.BACK)
		#else
		if (FlxG.keys.pressed.ESCAPE)
		#end
		System.exit(0);
	}
}
