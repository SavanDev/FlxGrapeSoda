package objects;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.util.FlxTimer;

enum Character
{
	Dylan;
	Luka;
	Watanoge;
	Asdonaur;
}

class Player extends FlxSprite
{
	public static inline var SPEED:Float = 75;
	static inline var GRAVITY:Float = 300;
	static inline var JUMP_POWER:Float = 100;

	public static var CHARACTER:Character = Dylan;
	public static var LIVES:Int = Game.MAX_LIVES;
	public static var POWERUP:Bool = false;

	public var canMove:Bool = true;
	public var animated:Bool = true;
	public var punchCallback:Void->Void;

	var jumping:Bool = false;
	var jumpTimer:Float = 0;

	public var isPunching:Bool = false;
	public var invencible:Bool = false;

	var respawning:Bool = false;
	var coyoteTime:Float = 0;

	function loadSkin(character:Character)
	{
		var skin:String;

		switch (CHARACTER)
		{
			case Dylan:
				skin = Paths.getImage("player/dylan");
			case Luka:
				skin = Paths.getImage("player/luka");
			case Watanoge:
				skin = Paths.getImage("player/watanoge");
			case Asdonaur:
				skin = Paths.getImage("player/asdonaur");
		}

		if (CHARACTER == Dylan && POWERUP)
		{
			loadGraphic(Paths.getImage("player/player"), true, 13, 26);

			// para las colisiones
			setSize(9, 24);
			offset.set(4, 2);

			// para las animaciones
			setFacingFlip(FlxObject.LEFT, true, false);
			setFacingFlip(FlxObject.RIGHT, false, false);
			animation.add("default", [0, 1, 2, 3], 3);
			animation.add("walk", [10, 11, 12, 13, 14, 15, 16, 17, 18, 19], 8);
			animation.add("jump", [20], 0);
		}
		else
		{
			loadGraphic(skin, true, 13, 20);

			// para las colisiones
			setSize(8, 18);
			offset.set(3, 2);

			// para las animaciones
			setFacingFlip(FlxObject.LEFT, true, false);
			setFacingFlip(FlxObject.RIGHT, false, false);
			animation.add("default", [1, 2], 3);
			animation.add("walk", [3, 4, 3, 5], 5);
			animation.add("jump", [6], 0);
			animation.add("sad", [9], 0);
			animation.add("happy", [10], 0);
			animation.add("punch", [12, 13, 14, 14, 13, 12], 12, false);
		}
	}

	override public function hurt(damage:Float)
	{
		if (!invencible)
		{
			trace("Player Hurt!");
			FlxG.sound.play(Paths.getSound("hurt"));
			LIVES -= Std.int(damage);
			if (PlayState.HUD != null)
				PlayState.HUD.updateLivesCounter(LIVES);
			super.hurt(damage);
		}
		invencible = true;
	}

	public function new(x:Float = 0, y:Float = 0, kinematic:Bool = false)
	{
		super(x, y);
		loadSkin(CHARACTER);
		canMove = !kinematic;

		health = LIVES;

		if (canMove)
		{
			this.drag.x = SPEED * 10;
			this.acceleration.y = GRAVITY;
		}
	}

	override function setPosition(X:Float = 0, Y:Float = 0)
	{
		x = X + offset.x;
		y = Y + offset.y;
	}

	function movement()
	{
		var elapsed:Float = FlxG.elapsed;
		var jump:Bool = Input.JUMP || Input.JUMP_ALT,
			left:Bool = Input.LEFT || Input.LEFT_ALT,
			right:Bool = Input.RIGHT || Input.RIGHT_ALT,
			punch:Bool = Input.PUNCH || Input.PUNCH_ALT;

		if (left && !right)
		{
			velocity.x = -SPEED;
			facing = FlxObject.LEFT;
		}

		if (right && !left)
		{
			velocity.x = SPEED;
			facing = FlxObject.RIGHT;
		}

		// sistema de salto (gracias HaxeFlixel Snippets!)
		if (jumping && !jump)
			jumping = false;

		if (jump && jumpTimer == -1 && coyoteTime <= .2)
			FlxG.sound.play(Paths.getSound("jump"));

		// coyote time
		if (isTouching(FlxObject.DOWN))
			coyoteTime = 0;
		else
			coyoteTime += elapsed;

		// reinicia el tiempo de salto al tocar el suelo
		if (coyoteTime <= .2 && !jumping)
			jumpTimer = 0;

		if (jumpTimer >= 0 && jump)
		{
			jumping = true;
			coyoteTime = 1;
			jumpTimer += elapsed;
		}
		else
			jumpTimer = -1;

		// mantener presionado para saltar más alto
		if (jumpTimer > 0 && jumpTimer < .25)
			velocity.y = -JUMP_POWER;

		if (CHARACTER == Luka)
		{
			if (punch && velocity.y == 0)
			{
				animation.play("punch");
				isPunching = true;
				if (punchCallback != null)
					punchCallback();
			}
		}
	}

	function playerAnimation()
	{
		if (!isTouching(FlxObject.DOWN) && canMove)
			animation.play("jump");
		else
		{
			if (!isPunching)
			{
				if (velocity.x != 0)
					animation.play("walk");
				else
					animation.play("default");
			}
			else
			{
				if (animation.finished)
					isPunching = false;
			}
		}
	}

	override function update(elapsed:Float)
	{
		FlxG.watch.add(this, "health");

		if (canMove && !isPunching)
			movement();
		if (animated)
			playerAnimation();

		if (invencible && !respawning)
		{
			FlxFlicker.flicker(this, 3);
			respawning = true;
			new FlxTimer().start(3, (_) ->
			{
				invencible = false;
				respawning = false;
				trace("Player is back!");
			});
		}

		super.update(elapsed);
	}
}
