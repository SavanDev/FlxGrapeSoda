package;

import Discord.State;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxTimer;

class Enemy extends FlxSprite
{
	var speed:Float = 35;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		loadGraphic(Paths.getImage("picky"), true, 12, 12);
		animation.add("default", [0, 1], 4);
		animation.add("dead", [2], 0);
		animation.play("default");

		velocity.x = speed;
	}

	override function update(elapsed:Float)
	{
		if (alive)
		{
			if (isTouching(FlxObject.RIGHT) && velocity.x >= 0)
			{
				facing = FlxObject.LEFT;
				velocity.x = -speed;
			}

			if (isTouching(FlxObject.LEFT) && velocity.x <= 0)
			{
				facing = FlxObject.RIGHT;
				velocity.x = speed;
			}
		}

		super.update(elapsed);
	}

	override function kill()
	{
		PlayState.ENEMIES_DEAD++;
		allowCollisions = FlxObject.NONE;
		velocity.x = velocity.y = 0;
		alive = false;
		FlxG.sound.play(Paths.getSound("picky"));
		velocity.x = 0;
		animation.play("dead");
		new FlxTimer().start(.5, function(timer:FlxTimer)
		{
			PlayState.MONEY += 15;
			#if (cpp && desktop)
			Discord.changePresence(State.Level, PlayState.discordPlayer, PlayState.discordTime);
			#end
			exists = false;
		});
	}
}
