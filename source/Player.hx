package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;

class Player extends FlxSprite
{
	public static inline var SPEED:Float = 75;
	public static var SKIN:String = Paths.getImage("player/dylan");
	static inline var GRAVITY:Float = 300;
	static inline var JUMP_POWER:Float = 100;

	public var canMove:Bool = true;
	public var animated:Bool = true;

	var jumping:Bool = false;
	var jumpTimer:Float = 0;

	public var isPunching:Bool = false;

	var touch1_X:Float;
	var touch2_X:Float;

	function loadSkin()
	{
		loadGraphic(SKIN, true, 12, 24);

		// para las colisiones
		setSize(8, 18);
		offset.set(2, 6);

		// para las animaciones
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		animation.add("default", [1], 5);
		animation.add("walk", [3, 4, 3, 5], 5);
		animation.add("jump", [6], 0);
		animation.add("sad", [9], 0);
		animation.add("happy", [10], 0);
		animation.add("punch", [12, 13, 14, 14, 13, 12], 12, false);
	}

	public function new(x:Float = 0, y:Float = 0, kinematic:Bool = false)
	{
		super(x, y);
		loadSkin();
		canMove = !kinematic;

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

	function movement(elapsed:Float)
	{
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

		if (jump && jumpTimer == -1 && isTouching(FlxObject.DOWN))
			FlxG.sound.play(Paths.getSound("jump"));

		// reinicia el tiempo de salto al tocar el suelo
		if (isTouching(FlxObject.DOWN) && !jumping)
			jumpTimer = 0;

		if (jumpTimer >= 0 && jump)
		{
			jumping = true;
			jumpTimer += elapsed;
		}
		else
			jumpTimer = -1;

		// mantener precionado para saltar más alto
		if (jumpTimer > 0 && jumpTimer < .25)
			velocity.y = -JUMP_POWER;

		if (punch && velocity.y == 0)
		{
			animation.play("punch");
			isPunching = true;
			velocity.x = 1;
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
		if (canMove && !isPunching)
			movement(elapsed);
		if (animated)
			playerAnimation();

		super.update(elapsed);
	}
}
