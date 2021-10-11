package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxBitmapText;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import lime.system.System;
import util.Menu;
#if desktop
import Discord.State;
#end

class MenuState extends BaseState
{
	var map:FlxOgmo3Loader;
	var tileMap:FlxTilemap;
	var player:Player;

	var logo:FlxSpriteGroup;
	var playText:FlxBitmapText;
	var versionText:FlxBitmapText;
	var playTimer:FlxTimer;

	static inline var LOGO_X = 63;
	static inline var LOGO_Y = 20;

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
		var menu = new Menu(10, 30);

		// Main Menu
		var newGame:MenuItem = {
			text: "New Game",
			event: (menu) ->
			{
				menu.kill();
				FlxG.sound.play(Paths.getSound("select"));
				FlxG.camera.fade(0xFF111111, () -> FlxG.switchState(new ReadyState()));
			}
		}

		var donate:MenuItem = {
			text: "Donate",
			event: (menu) -> {
				#if linux
				Sys.command('xdg-open', ["https://ko-fi.com/savandev"]);
				#else
				FlxG.openURL("https://ko-fi.com/savandev");
				#end
			}
		}

		var options:MenuItem = {
			text: "Options",
			event: (menu) -> menu.gotoPage("options")
		}

		var exit:MenuItem = {
			text: "Exit",
			event: (menu) -> System.exit(0)
		}

		#if desktop
		menu.addPage("main", [newGame, options, exit]);
		#elseif (android || web)
		menu.addPage("main", [newGame, donate]);
		#end

		// Options Menu
		var optFullWindow:MenuItem = {
			text: FlxG.fullscreen ? "Window mode" : "Fullscreen",
			event: (menu) ->
			{
				FlxG.fullscreen = !FlxG.fullscreen;
				FlxG.save.data.fullScreen = FlxG.fullscreen;
				menu.changeOptionName(FlxG.fullscreen ? "Window mode" : "Fullscreen");
			}
		}

		var optMusicOff:MenuItem = {
			text: 'Sound: ${FlxG.sound.muted ? "OFF" : "ON"}',
			event: (menu) ->
			{
				FlxG.sound.toggleMuted();
				FlxG.save.data.soundsEnabled = FlxG.sound.muted;
				menu.changeOptionName('Sound: ${FlxG.sound.muted ? "OFF" : "ON"}');
			}
		}

		var optBack:MenuItem = {
			text: "Back",
			event: (menu) -> menu.gotoPage("main")
		}

		#if desktop
		menu.addPage("options", [optFullWindow, optMusicOff, donate, optBack]);
		#end

		menu.gotoPage("main");

		FlxTween.num(logo.x, logo.x + 50, .5, (v) -> logo.x = v);
		new FlxTimer().start(.5, (tmr) -> add(menu));
	}

	override public function create()
	{
		super.create();

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

		// start!
		var startText:String;
		#if mobile
		startText = "Tap to start!";
		#else
		startText = "Press ENTER!";
		#end

		playText = new FlxBitmapText(Fonts.DEFAULT);
		playText.text = startText;
		playText.fieldWidth = 200;
		playText.alignment = CENTER;
		playText.useTextColor = true;
		playText.screenCenter(X);
		playText.y = 65;
		add(playText);

		playTimer = new FlxTimer().start(1, playBlink, 0);

		// logo
		var logoX = FlxG.width / 2 - LOGO_X;
		logo = new FlxSpriteGroup(logoX, LOGO_Y);

		var logoText1 = new FlxBitmapText(Fonts.PF_ARMA_FIVE);
		logoText1.text = "Latin American needs...";

		var logoText2 = new FlxBitmapText(Fonts.PF_ARMA_FIVE_16);
		logoText2.text = "GRAPE SODA!";
		logoText2.setBorderStyle(OUTLINE, 0xFF5B315B);
		logoText2.setPosition(0, 5);

		var logoSoda = new FlxSprite(100, 0);
		logoSoda.loadGraphic(Paths.getImage("items/grapesoda"), false, 12, 14);
		logoSoda.setGraphicSize(24, 28);
		logoSoda.updateHitbox();
		logoSoda.angle = -10;

		logo.add(logoText1);
		logo.add(logoText2);
		logo.add(logoSoda);
		add(logo);

		FlxTween.num(LOGO_Y, LOGO_Y + 3, .5, {type: PINGPONG}, (v:Float) -> logo.y = v);

		// Escenario
		FlxG.camera.bgColor = 0xFF64A5FF;

		// fondo
		var parallax = new FlxBackdrop(Paths.getImage("parallax/mountain"), 1, 1, true, false);
		parallax.y = 65;
		add(parallax);

		// mini nivel
		map = new FlxOgmo3Loader(Paths.getOgmoData(), Paths.getMap("menuMap"));
		tileMap = map.loadTilemap(Paths.getImage("legacy/tileMap"), "Blocks");
		add(tileMap);
		player = new Player(0, 0, true);
		map.loadEntities(entitiesPos, "Entities");
		add(player);

		// musica
		if (FlxG.sound.music != null)
			FlxG.camera.fade(.5, true);
		FlxG.sound.playMusic(Paths.getMusic("effervesce"));

		// texto de la versión
		versionText = new FlxBitmapText(Fonts.TOY);
		#if nightly
		versionText.text = 'Nightly version';
		#else
		versionText.text = 'v${Application.current.meta.get("version")}';
		#end
		versionText.alignment = RIGHT;
		versionText.setPosition(FlxG.width - versionText.getStringWidth(versionText.text) - 10, FlxG.height - 15);
		add(versionText);

		var kofi:FlxSprite = new FlxSprite(5, FlxG.height - 15);
		kofi.loadGraphic(Paths.getImage("kofi"));
		add(kofi);

		// FIXME: Pequeño arreglo temporal. Luego voy a tener que estudiar un poco más el sistema de sonidos.
		FlxG.sound.defaultSoundGroup.volume = .5;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		#if desktop
		if (Input.isGamepadConnected)
		{
			playText.text = "Press A!";
			playText.screenCenter(X);
		}
		else
		{
			playText.text = "Press ENTER!";
			playText.screenCenter(X);
		}
		#end

		// Si el jugador aún sigue en la pantalla "Press XXXXX!"
		if (playTimer.time != .1 && (Input.SELECT || Input.SELECT_ALT))
			startGame();

		// Una vez que el jugador se sale de la pantalla, muestra el menú
		if (player.alive && !player.isOnScreen())
			showMenu();

		if (Input.BACK || Input.BACK_ALT)
			System.exit(0);
	}
}
