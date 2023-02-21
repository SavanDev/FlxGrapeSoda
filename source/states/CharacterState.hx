package states;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class CharacterState extends BaseState
{
	var playerViewer:FlxSprite;
	var characterSelected:Int = 0;
	var powerup:Bool = false;

	var animState:FlxText;
	var charName:FlxText;

	function changeSkin()
	{
		var skin:String = "";
		switch (characterSelected)
		{
			case 0:
				charName.text = "Dylan";
				skin = Paths.getImage("skins/dylan");
			case 1:
				charName.text = "Luka";
				skin = Paths.getImage("skins/luka");
			case 2:
				charName.text = "Watanoge";
				skin = Paths.getImage("skins/watanoge");
			case 3:
				charName.text = "Asdonaur";
				skin = Paths.getImage("skins/asdonaur");
		}

		playerViewer.loadGraphic(skin, true, 12, 24);

		// para las colisiones
		playerViewer.setSize(8, 18);
		playerViewer.offset.set(3, 6);

		// para las animaciones
		playerViewer.setFacingFlip(FlxObject.LEFT, true, false);
		playerViewer.setFacingFlip(FlxObject.RIGHT, false, false);
		playerViewer.animation.add("default", [1, 2], 3);
		playerViewer.animation.add("walk", [3, 4, 3, 5], 5);
		playerViewer.animation.add("jump", [6], 0);
		playerViewer.animation.add("sad", [7], 0);
		playerViewer.animation.add("sadness", [8], 0);
		playerViewer.animation.add("punch", [9, 10, 11, 11, 10, 9], 12);

		playerViewer.setGraphicSize(Std.int(playerViewer.width * 5));
		playerViewer.screenCenter();
		playerViewer.animation.play("default");
	}

	override function create()
	{
		super.create();
		FlxG.camera.bgColor = FlxColor.GRAY;

		charName = new FlxText(10, 10);
		animState = new FlxText(10, 20, "DEFAULT");

		playerViewer = new FlxSprite();
		changeSkin();

		add(charName);
		add(animState);
		add(playerViewer);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		#if desktop
		// animaciones
		if (FlxG.keys.justPressed.RIGHT)
		{
			playerViewer.facing = RIGHT;
			playerViewer.animation.play("walk");
			animState.text = "Walk (RIGHT)";
		}

		if (FlxG.keys.justPressed.LEFT)
		{
			playerViewer.facing = LEFT;
			playerViewer.animation.play("walk");
			animState.text = "Walk (LEFT)";
		}

		if (FlxG.keys.justPressed.UP)
		{
			playerViewer.facing = RIGHT;
			playerViewer.animation.play("jump");
			animState.text = "JUMP";
		}

		if (FlxG.keys.justPressed.DOWN)
		{
			playerViewer.facing = RIGHT;
			playerViewer.animation.play("default");
			animState.text = "DEFAULT";
		}

		if (FlxG.keys.justPressed.END)
		{
			playerViewer.facing = RIGHT;
			playerViewer.animation.play("sad");
			animState.text = "SAD";
		}

		if (FlxG.keys.justPressed.HOME)
		{
			playerViewer.facing = FlxObject.RIGHT;
			playerViewer.animation.play("sadness");
			animState.text = "SADNESS";
		}

		// cambiar jugadores
		if (FlxG.keys.justPressed.ONE)
		{
			characterSelected = 0;
			changeSkin();
		}

		if (FlxG.keys.justPressed.TWO)
		{
			characterSelected = 1;
			changeSkin();
		}

		if (FlxG.keys.justPressed.THREE)
		{
			characterSelected = 2;
			changeSkin();
		}

		if (FlxG.keys.justPressed.FOUR)
		{
			characterSelected = 3;
			changeSkin();
		}

		// para salir
		if (FlxG.keys.justPressed.ESCAPE)
			FlxG.switchState(new PlayState());
		#end
	}
}
