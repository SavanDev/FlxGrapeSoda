import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxBitmapText;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;

typedef PlayerData =
{
	var player:String;
}

class ReadyState extends FlxState
{
	function startCallback(timer:FlxTimer):Void
	{
		if (Assets.exists(Paths.getLevel(PlayState.LEVEL)))
			FlxG.switchState(new PlayState());
		else
			FlxG.switchState(new DemoState());
	}

	override public function create()
	{
		super.create();
		this.bgColor = 0xFF111111;

		if (Assets.exists(Paths.getLevel(PlayState.LEVEL)))
		{
			var level:PlayerData = Json.parse(Assets.getText(Paths.getLevel(PlayState.LEVEL)));
			Player.SKIN = Paths.getImage('player/${level.player}');
		}

		// mostrar nivel
		var levelText = new FlxBitmapText(Fonts.DEFAULT_16);
		levelText.text = 'Level ${PlayState.LEVEL}';
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

		if (FlxG.sound.music != null)
			FlxG.sound.music.destroy();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
