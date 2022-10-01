package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;

typedef ComicFile =
{
	var music:Null<String>;
	// var bgColor:Null<String>;
	var states:Array<ComicJSON>;
}

typedef ComicJSON =
{
	var pos:Null<String>;
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
	var imgComics:FlxSpriteGroup;
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

		FlxG.camera.fade(.5, true);

		/*var background:FlxSprite = new FlxSprite();
			background.loadGraphic(Paths.getImage("cutscenes/comic-background"));
			background.alpha = .75;
			add(background); */

		imgComics = new FlxSpriteGroup();
		imgComics.setPosition(Game.TILE_SIZE, Game.TILE_SIZE);

		imgFull = new FlxSprite();
		imgFull.visible = false;

		add(imgComics);
		add(imgFull);

		// start comic
		comic = Json.parse(Assets.getText('assets/data/cutscenes/$comicName.json'));
		new FlxTimer().start(2, readComic, 0);

		if (comic.music != null)
			FlxG.sound.playMusic(Paths.getMusic(comic.music));

		#if !mobile
		var skipString:String = "Press ENTER to skip!";
		if (Input.isGamepadConnected)
			skipString = "Press A to skip!";
		#else
		var skipString:String = "Tap to skip!";
		#end

		var skipText:FlxText = new FlxText(8, skipString);
		skipText.y = Game.HEIGHT - skipText.height - (Game.TILE_SIZE / 2);
		skipText.color = FlxColor.WHITE;
		add(skipText);

		new FlxTimer().start(3, (_) -> FlxTween.num(1, 0, 2, (v) -> skipText.alpha = v));
	}

	function showNormalComic(image:String, width:Int = 0, height:Int = 0, ?anim:Array<Int>, frameSpeed:Int = 2, loop:Bool = true)
	{
		var imgComic = new FlxSprite();

		if (imgComics.length > 0)
		{
			var lastComic = imgComics.members[imgComics.length - 1];
			imgComic.setPosition(lastComic.x + lastComic.width);
		}

		imgComic.loadGraphic(Paths.getImage(image), anim != null, width, height);
		if (anim != null)
		{
			imgComic.animation.add("default", anim, frameSpeed, loop);
			imgComic.animation.play("default");
		}
		FlxTween.num(0, 1, .5, (v) -> imgComic.alpha = v);
		imgComics.add(imgComic);
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
		FlxTween.num(1, .75, .5, (v) -> imgComics.alpha = v);
	}

	function playSound(sound:String)
	{
		FlxG.sound.play(Paths.getSound(sound));
		FlxTween.num(.25, 1, 1.5, (v) -> FlxG.sound.music.volume = v);
	}

	function hideComics()
	{
		imgComics.forEach((comicVignette) -> comicVignette.destroy());
		imgComics.clear();

		imgFull.visible = false;
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
			case "full":
				showFullComic(page.image, page.width != null ? page.width : 0, page.height != null ? page.height : 0, page.frames,
					page.speed != null ? page.speed : 2, page.loop != null ? page.loop : true);
			case "hide":
				hideComics();
			default:
				showNormalComic(page.image, page.width != null ? page.width : 0, page.height != null ? page.height : 0, page.frames,
					page.speed != null ? page.speed : 2, page.loop != null ? page.loop : true);
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
