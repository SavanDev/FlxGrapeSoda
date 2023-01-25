package objects;

import flixel.FlxG;
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
	static inline var JUMP_POWER:Float = 100;

	public static var CHARACTER:Character = Dylan;
	public static var LIVES:Int = Game.MAX_LIVES;

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

		switch (character)
		{
			case Dylan:
				skin = Paths.getImage("skins/dylan");
			case Luka:
				skin = Paths.getImage("skins/luka");
			case Watanoge:
				skin = Paths.getImage("skins/watanoge");
			case Asdonaur:
				skin = Paths.getImage("skins/asdonaur");
		}
		loadGraphic(skin, true, 12, 24);

		// para las colisiones
		setSize(7, 18);
		offset.set(2, 6);

		// para las animaciones
		setFacingFlip(LEFT, true, false);
		setFacingFlip(RIGHT, false, false);
		animation.add("default", [1, 2], 3);
		animation.add("walk", [3, 4, 3, 5], 5);
		animation.add("jump", [6], 0);
		animation.add("sad", [7], 0);
		animation.add("sadness", [8], 0);
		animation.add("punch", [9, 10, 11, 11, 10, 9], 12, false);
	}

	override public function hurt(damage:Float)
	{
		if (!invencible)
		{
			trace("Player Hurt!");
			FlxG.camera.shake(.01, .15);
			FlxG.sound.play(Paths.getSound("hurt"));
			LIVES -= Std.int(damage);
			if (Gameplay.HUD != null)
				Gameplay.HUD.updateLivesCounter(LIVES);
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
			this.acceleration.y = Gameplay.GRAVITY;
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
			facing = LEFT;
		}

		if (right && !left)
		{
			velocity.x = SPEED;
			facing = RIGHT;
		}

		// sistema de salto (gracias HaxeFlixel Snippets!)
		if (jumping && !jump)
			jumping = false;

		if (jump && jumpTimer == -1 && coyoteTime <= .2)
			FlxG.sound.play(Paths.getSound("jump"));

		// coyote time
		if (isTouching(DOWN))
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

		// mantener precionado para saltar más alto
		if (jumpTimer > 0 && jumpTimer < .25)
			velocity.y = -JUMP_POWER;

		if (punch && velocity.y == 0)
		{
			animation.play("punch");
			isPunching = true;
			if (punchCallback != null)
				punchCallback();
		}

		if (facing == LEFT)
			offset.set(3, 6);

		if (facing == RIGHT)
			offset.set(2, 6);
	}

	function playerAnimation()
	{
		if (!isTouching(DOWN) && canMove)
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
