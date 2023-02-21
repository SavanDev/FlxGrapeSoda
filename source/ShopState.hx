package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import objects.Player;

class ShopState extends BaseState
{
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

		FlxG.camera.bgColor = FlxColor.BLACK;

		var background = new FlxSprite();
		background.loadGraphic(Paths.getImage("shopInterior"));
		background.y = Game.HEIGHT - background.height;
		background.screenCenter(X);
		add(background);

		player = new Player(background.x + 10, 116, true);
		player.velocity.x = Player.SPEED / 2;
		add(player);

		cajera = new FlxSprite(background.x + 90, 110);
		cajera.loadGraphic(Paths.getImage("cashier"), true, 12, 24);
		cajera.animation.add("default", [0, 1], 4);
		cajera.animation.add("angry", [3, 4], 4);
		cajera.animation.add("money", [6, 7], 4);
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
		if (Gameplay.MONEY > 0)
			scoreTween = FlxTween.num(score, Gameplay.MONEY, Gameplay.MONEY * .05, {ease: FlxEase.linear, onComplete: counterEnd}, onMoneyCount);
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
			moneyCounter.text = Std.string(Gameplay.MONEY);
			counterEnd(scoreTween);
		}
	}

	function counterEnd(tween:FlxTween)
	{
		if (Gameplay.MONEY >= Gameplay.GRAPESODA_PRICE)
			FlxG.sound.music.stop();

		new FlxTimer().start(1.5, shopEnding);
	}

	function shopEnding(timer:FlxTimer)
	{
		if (Gameplay.MONEY < Gameplay.GRAPESODA_PRICE)
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
				Gameplay.LEVEL += 1;
				FlxG.switchState(Gameplay.STORY_MODE ? new ReadyState() : new MenuState());
			});
		}
		else
		{
			cajera.animation.play("money");
			player.animated = false;
			player.animation.play("happy");
			FlxG.sound.playMusic(Paths.getMusic("deities-get-takeout-too"));

			// Muchas muertes :'(
			moneyIcon.kill();
			moneyCounter.kill();
			scoreGet.kill();

			var youDid:FlxBitmapText = new FlxBitmapText(Fonts.DEFAULT_16);
			youDid.setPosition(0, 30);
			youDid.text = "YOU DID IT!";
			youDid.useTextColor = true;
			youDid.textColor = FlxColor.YELLOW;
			youDid.alignment = CENTER;
			youDid.screenCenter(X);
			add(youDid);

			new FlxTimer().start(.1, (tmr) -> youDid.textColor = youDid.textColor == FlxColor.YELLOW ? FlxColor.WHITE : FlxColor.YELLOW, 0);
			FlxTween.shake(youDid, .05, 1, {type: LOOPING});

			var destello:FlxSprite = new FlxSprite();
			destello.loadGraphic(Paths.getImage("hud/win"), true, 24, 24);
			destello.animation.add("default", [0, 1], 4);
			destello.animation.play("default");
			destello.setPosition(player.x + player.width / 2 - destello.width / 2, player.y - 5 - destello.height);
			add(destello);

			var grapesoda:FlxSprite = new FlxSprite(destello.x + 6, destello.y + 6, Paths.getImage("items/grapesoda"));
			add(grapesoda);

			if (!Gameplay.STORY_MODE)
				new FlxTimer().start(3.5, (tmr) -> FlxG.switchState(new MenuState()));
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
