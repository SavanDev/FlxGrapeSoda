package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import objects.Player;
#if desktop
import Discord.State;
#end

class ShopState extends BaseState
{
	static final INITIAL_X:Int = 45;
	static final GRAPESODA_PRICE:Int = 500;

	var player:Player;
	var cajera:FlxSprite;

	var moneyIcon:FlxSprite;
	var moneyCounter:FlxBitmapText;
	var scoreGet:FlxBitmapText;

	var score:Int = 0;
	var scoreTween:FlxTween;

	override public function create()
	{
		super.create();

		#if (cpp && desktop)
		Discord.changePresence(State.Shop);
		#end

		bgColor = FlxColor.BLACK;

		var background = new FlxSprite(INITIAL_X);
		background.loadGraphic(Paths.getImage("shopInterior"));
		add(background);

		player = new Player(INITIAL_X, 116, true);
		player.velocity.x = Player.SPEED / 2;
		add(player);

		cajera = new FlxSprite(INITIAL_X + 88, 110);
		cajera.loadGraphic(Paths.getImage("cashier"), true, 12, 24);
		cajera.animation.add("default", [0, 1], 4);
		cajera.animation.add("angry", [3, 4], 4);
		cajera.animation.play("default");
		add(cajera);

		moneyIcon = new FlxSprite(0, 40);
		moneyIcon.loadGraphic(Paths.getImage("items/coin"), true, 12, 12);
		moneyIcon.screenCenter(X);
		moneyIcon.x -= 10;

		moneyCounter = new FlxBitmapText(Fonts.DEFAULT);
		moneyCounter.setPosition(0, 41);
		moneyCounter.screenCenter(X);

		scoreGet = new FlxBitmapText(Fonts.DEFAULT);
		scoreGet.text = "You get...";
		scoreGet.setPosition(0, 25);
		scoreGet.screenCenter(X);
		scoreGet.alignment = CENTER;

		FlxG.camera.fade(FlxColor.BLACK, 1.5, true, () ->
		{
			player.velocity.x = 0;
			add(scoreGet);
			new FlxTimer().start(1.0, moneyCount, 1);
		});

		FlxG.sound.playMusic(Paths.getMusic("turtle-nap"));
	}

	function moneyCount(timer:FlxTimer)
	{
		add(moneyIcon);
		add(moneyCounter);
		if (PlayState.MONEY > 0)
			scoreTween = FlxTween.num(score, PlayState.MONEY, PlayState.MONEY * .05, {ease: FlxEase.linear, onComplete: counterEnd}, onMoneyCount);
		else
			counterEnd(null);
	}

	function onMoneyCount(v:Float)
	{
		var counter:Int = Math.round(v);

		if (score != counter)
			FlxG.sound.play(Paths.getSound("coin"));

		score = counter;
		moneyCounter.text = Std.string(score);

		if (Input.SELECT || Input.SELECT_ALT)
		{
			scoreTween.cancel();
			moneyCounter.text = Std.string(PlayState.MONEY);
			counterEnd(scoreTween);
		}
	}

	function counterEnd(tween:FlxTween)
	{
		new FlxTimer().start(1.5, shopEnding);
	}

	function shopEnding(timer:FlxTimer)
	{
		if (PlayState.MONEY < GRAPESODA_PRICE)
		{
			trace("tas pobre bro :P");
			FlxG.sound.play(Paths.getSound("failed"));
			FlxG.sound.music.stop();
			cajera.animation.play("angry");
			player.animated = false;
			player.animation.play("sad");

			// Muchas muertes :'(
			moneyIcon.kill();
			moneyCounter.kill();
			scoreGet.kill();

			var notEnough:FlxBitmapText = new FlxBitmapText(Fonts.DEFAULT_16);
			notEnough.setPosition(0, 20);
			notEnough.text = "THAT'S NOT\nENOUGH!";
			notEnough.useTextColor = true;
			notEnough.textColor = FlxColor.RED;
			notEnough.alignment = CENTER;
			notEnough.screenCenter(X);
			add(notEnough);

			FlxG.camera.shake(0.025, 2, () ->
			{
				PlayState.LEVEL += 1;
				FlxG.switchState(new ReadyState());
			});
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
