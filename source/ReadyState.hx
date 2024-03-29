import Gameplay;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxBitmapText;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import objects.Player;
import states.ComicState;
import states.PlayState;
import sys.FileSystem;
import sys.io.File;

class ReadyState extends BaseState
{
	static public var SHOW_CUTSCENE:Bool = true;

	var loadCutscene:Bool = false;

	override public function create()
	{
		super.create();
		FlxG.camera.bgColor = 0xFF111111;
		var level = Gameplay.STORY_MODE ? Paths.getLevel(Gameplay.LEVEL) : Paths.getCustomLevel(Gameplay.LEVELNAME);
		var levelExists = FileSystem.exists(level);
		trace(levelExists);

		if (levelExists)
		{
			var level:MinimalLevelData = Json.parse(File.getContent(level));

			if (level.cutscene != null
				&& Assets.exists('assets/data/cutscenes/${level.cutscene}.json')
				&& SHOW_CUTSCENE) // TODO: Custom Cutscenes
			{
				SHOW_CUTSCENE = false;
				loadCutscene = true;
				FlxG.switchState(new ComicState(level.cutscene, ReadyState));
			}

			switch (level.player)
			{
				case 0:
					Player.CHARACTER = Dylan;
				case 1:
					Player.CHARACTER = Luka;
				case 2:
					Player.CHARACTER = Watanoge;
				case 3:
					Player.CHARACTER = Asdonaur;
			}
		}

		if (!loadCutscene)
		{
			// mostrar nivel
			var levelText = new FlxBitmapText(Fonts.DEFAULT_16);
			levelText.text = Gameplay.STORY_MODE ? (levelExists ? 'Level ${Gameplay.LEVEL}' : 'BAD END') : 'Freeplay';
			levelText.screenCenter();
			levelText.y -= 35;
			add(levelText);

			// mostrar jugador actual
			var player = new Player(0, 0, true);
			player.setGraphicSize(24, 48);
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
			moneyCount.text = 'x ${Gameplay.MONEY}';
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

			new FlxTimer().start(2, (tmr) ->
			{
				SHOW_CUTSCENE = true;
				FlxG.switchState(levelExists ? new PlayState() : new MenuState());
			});
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.destroy();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
