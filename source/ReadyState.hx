import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxBitmapText;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import objects.Player;
import states.ComicState;

typedef PlayerData =
{
	var player:String;
	var cutscene:String;
}

class ReadyState extends BaseState
{
	static public var SHOW_CUTSCENE:Bool = true;

	var loadCutscene:Bool = false;

	function startCallback(timer:FlxTimer):Void
	{
		SHOW_CUTSCENE = true;
		FlxG.switchState(new PlayState());
	}

	override public function create()
	{
		super.create();
		FlxG.camera.bgColor = 0xFF111111;
		var levelExists = Assets.exists(Paths.getLevel(PlayState.LEVEL));

		if (levelExists)
		{
			var level:PlayerData = Json.parse(Assets.getText(Paths.getLevel(PlayState.LEVEL)));

			if (level.cutscene != null && Assets.exists('assets/data/cutscenes/${level.cutscene}.json') && SHOW_CUTSCENE)
			{
				SHOW_CUTSCENE = false;
				loadCutscene = true;
				FlxG.switchState(new ComicState(level.cutscene, ReadyState));
			}

			Player.SKIN = Paths.getImage('player/${level.player}');
		}
		else
			PlayState.DEMO_END = true;

		if (!loadCutscene)
		{
			// mostrar nivel
			var levelText = new FlxBitmapText(Fonts.DEFAULT_16);
			levelText.text = !PlayState.DEMO_END ? 'Level ${PlayState.LEVEL}' : 'Demo End';
			levelText.screenCenter();
			levelText.y -= 35;
			add(levelText);

			// mostrar jugador actual
			var player = new Player(0, 0, true);
			player.setGraphicSize(26, 40);
			player.screenCenter();
			player.x -= 30;
			add(player);

			var moneyIcon = new FlxSprite();
			moneyIcon.loadGraphic(Paths.getImage("items/coin"), true, 12, 12);
			moneyIcon.screenCenter();
			moneyIcon.x += 5;
			add(moneyIcon);

			var moneyCount = new FlxBitmapText(Fonts.DEFAULT);
			moneyCount.screenCenter();
			moneyCount.text = 'x ${PlayState.MONEY}';
			moneyCount.y++;
			moneyCount.x += 15;
			add(moneyCount);

			// get ready?
			var getReadyText = new FlxBitmapText(Fonts.DEFAULT);
			getReadyText.text = "Get Ready?";
			getReadyText.screenCenter();
			getReadyText.x += 20;
			getReadyText.y += 15;
			add(getReadyText);

			new FlxTimer().start(2, startCallback);
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.destroy();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
