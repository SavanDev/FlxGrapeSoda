package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;

typedef ComicFile =
{
	var music:Null<String>;
	var states:Array<ComicJSON>;
}

typedef ComicJSON =
{
	var pos:String;
	var image:String;
	var width:Null<Int>;
	var height:Null<Int>;
	var frames:Null<Array<Int>>;
	var speed:Null<Int>;
	var loop:Null<Bool>;
	var time:Null<Int>;
	var sound:Null<String>;
}

class ComicState extends BaseState
{
	var comicName:String;
	var finalState:Class<FlxState>;

	var comic:ComicFile;
	var imgLeft:FlxSprite;
	var imgCenter:FlxSprite;
	var imgRight:FlxSprite;
	var imgFull:FlxSprite;

	var comicState:Int = 0;
	var skipped:Bool = false;

	public function new(name:String, goTo:Class<FlxState>)
	{
		super();
		comicName = name;
		finalState = goTo;
	}

	override function create()
	{
		super.create();

		imgLeft = new FlxSprite(Game.TILE_SIZE, Game.TILE_SIZE);
		imgCenter = new FlxSprite();
		imgRight = new FlxSprite();
		imgFull = new FlxSprite();

		imgLeft.visible = false;
		imgRight.visible = false;
		imgCenter.visible = false;
		imgFull.visible = false;

		add(imgLeft);
		add(imgCenter);
		add(imgRight);
		add(imgFull);

		// start comic
		comic = Json.parse(Assets.getText('assets/data/cutscenes/$comicName.json'));
		trace(comic);
		new FlxTimer().start(2, readComic, 0);

		if (comic.music != null)
			FlxG.sound.playMusic(Paths.getMusic(comic.music));

		var skipString:String = "Press ENTER to skip!";
		if (Input.isGamepadConnected)
			skipString = "Press A to skip!";

		var skipText:FlxText = new FlxText(8, skipString);
		skipText.y = Game.HEIGHT - skipText.height - (Game.TILE_SIZE / 2);
		skipText.color = FlxColor.WHITE;
		add(skipText);

		new FlxTimer().start(3, (_) -> FlxTween.num(1, 0, 2, (v) -> skipText.alpha = v));
	}

	function showLeftComic(image:String, width:Int = 0, height:Int = 0, ?anim:Array<Int>, frameSpeed:Int = 2, loop:Bool = true)
	{
		imgLeft.loadGraphic(Paths.getImage(image), anim != null, width, height);
		if (anim != null)
		{
			imgLeft.animation.add("default", anim, frameSpeed, loop);
			imgLeft.animation.play("default");
		}
		FlxTween.num(0, 1, .5, (v) -> imgLeft.alpha = v);
		imgLeft.visible = true;
	}

	function showCenterComic(image:String, width:Int = 0, height:Int = 0, ?anim:Array<Int>, frameSpeed:Int = 2, loop:Bool = true)
	{
		imgCenter.loadGraphic(Paths.getImage(image), anim != null, width, height);
		imgCenter.setPosition(imgLeft.x + imgLeft.width + Game.TILE_SIZE, Game.TILE_SIZE);
		if (anim != null)
		{
			imgCenter.animation.add("default", anim, frameSpeed, loop);
			imgCenter.animation.play("default");
		}
		FlxTween.num(0, 1, .5, (v) -> imgCenter.alpha = v);
		imgCenter.visible = true;
		FlxTween.num(1, .5, .5, (v) -> imgLeft.alpha = v);
		if (imgLeft.animation.name != null)
			imgLeft.animation.stop();
	}

	function showRightComic(image:String, width:Int = 0, height:Int = 0, ?anim:Array<Int>, frameSpeed:Int = 2, loop:Bool = true)
	{
		imgRight.loadGraphic(Paths.getImage(image), anim != null, width, height);
		imgRight.setPosition(imgCenter.x + imgCenter.width + Game.TILE_SIZE, Game.TILE_SIZE);
		if (anim != null)
		{
			imgRight.animation.add("default", anim, frameSpeed, loop);
			imgRight.animation.play("default");
		}
		FlxTween.num(0, 1, .5, (v) -> imgRight.alpha = v);
		imgRight.visible = true;
		FlxTween.num(1, .5, .5, (v) -> imgCenter.alpha = v);
		if (imgCenter.animation.name != null)
			imgCenter.animation.stop();
	}

	function showFullComic(image:String, width:Int = 0, height:Int = 0, ?anim:Array<Int>, frameSpeed:Int = 2, loop:Bool = true)
	{
		imgFull.loadGraphic(Paths.getImage(image), anim != null, width, height);
		imgFull.visible = true;
		if (anim != null)
		{
			imgFull.animation.add("default", anim, frameSpeed, loop);
			imgFull.animation.play("default");
		}
		imgRight.alpha = .5;
		if (imgRight.animation.name != null)
			imgRight.animation.stop();
	}

	function playSound(sound:String)
	{
		FlxG.sound.play(Paths.getSound(sound));
		FlxTween.num(.25, 1, 1.5, (v) -> FlxG.sound.music.volume = v);
	}

	function hideComics()
	{
		imgLeft.visible = false;
		imgCenter.visible = false;
		imgRight.visible = false;
		imgFull.visible = false;

		imgLeft.alpha = 1;
		imgCenter.alpha = 1;
		imgRight.alpha = 1;
		imgFull.alpha = 1;
	}

	function readComic(tmr:FlxTimer)
	{
		if (comicState >= comic.states.length)
		{
			FlxTween.num(1, 0, 3, {onComplete: (_) -> FlxG.sound.music.stop()}, (v) -> FlxG.sound.music.volume = v);
			FlxG.camera.fade(4, () -> FlxG.switchState(new MenuState()));
			tmr.cancel();
			return;
		}

		var page = comic.states[comicState];
		switch (page.pos)
		{
			case "left":
				showLeftComic(page.image, page.width != null ? page.width : 0, page.height != null ? page.height : 0, page.frames,
					page.speed != null ? page.speed : 2, page.loop != null ? page.loop : true);
			case "center":
				showCenterComic(page.image, page.width != null ? page.width : 0, page.height != null ? page.height : 0, page.frames,
					page.speed != null ? page.speed : 2, page.loop != null ? page.loop : true);
			case "right":
				showRightComic(page.image, page.width != null ? page.width : 0, page.height != null ? page.height : 0, page.frames,
					page.speed != null ? page.speed : 2, page.loop != null ? page.loop : true);
			case "full":
				showFullComic(page.image, page.width != null ? page.width : 0, page.height != null ? page.height : 0, page.frames,
					page.speed != null ? page.speed : 2, page.loop != null ? page.loop : true);
			case "hide":
				hideComics();
		}

		if (page.time != null)
			tmr.time = page.time;

		if (page.sound != null)
			playSound(page.sound);

		comicState++;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!skipped && (Input.SELECT || Input.SELECT_ALT))
		{
			FlxG.camera.fade(2, () -> FlxG.switchState(Type.createInstance(finalState, [])));
			skipped = true;
		}
	}
}
