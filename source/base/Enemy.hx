package;

import Discord.State;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxTimer;

class Enemy extends FlxSprite
{
	public var speed:Float = 35;
	public var direction:Int = 1;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		loadGraphic(Paths.getImage("picky"), true, 12, 12);
		animation.add("default", [0, 1], 4);
		animation.add("dead", [2], 0);
		animation.play("default");
	}

	override function kill()
	{
		PlayState.ENEMIES_DEAD++;
		allowCollisions = FlxObject.NONE;
		alive = false;
		velocity.x = velocity.y = 0;
		FlxG.sound.play(Paths.getSound("picky"));
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

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (alive)
			velocity.x = speed * direction;
	}
}
