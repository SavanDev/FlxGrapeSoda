package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;

class Enemy extends FlxSprite
{
	public var speed:Float = 35;
	public var direction:Int = -1;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		loadGraphic(Paths.getImage("enemies/picky"), true, 12, 12);
		animation.add("default", [0, 1], 4);
		animation.add("dead", [2], 0);
		animation.play("default");

		setSize(8, 12);
		offset.set(2, 0);

		this.acceleration.y = Gameplay.GRAVITY;
	}

	override function kill()
	{
		this.acceleration.y = 0;
		this.velocity.y = -35;

		allowCollisions = NONE;
		alive = false;
		velocity.x = 0;
		FlxG.sound.play(Paths.getSound("picky"));
		animation.play("dead");

		new FlxTimer().start(.5, function(timer:FlxTimer)
		{
			Gameplay.MONEY += 15;
			if (Gameplay.HUD != null)
				Gameplay.HUD.updateMoneyCounter(Gameplay.MONEY);
			exists = false;
		});
	}

	override function update(elapsed:Float)
	{
		if (isTouching(LEFT) || isTouching(RIGHT))
			direction = -direction;

		super.update(elapsed);

		if (alive)
			velocity.x = speed * direction;
	}
}
