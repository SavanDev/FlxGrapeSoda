package;

import flixel.FlxG;
#if android
import flixel.input.android.FlxAndroidKey;
#else
import flixel.input.keyboard.FlxKey;
#end

class Input
{
	// Controles principales
	public static var UP:Bool;
	public static var DOWN:Bool;
	public static var LEFT:Bool;
	public static var RIGHT:Bool;
	public static var JUMP:Bool;
	public static var PUNCH:Bool;
	public static var SELECT:Bool;
	public static var BACK:Bool;
	public static var PAUSE:Bool;

	// Controles alternos
	public static var UP_ALT:Bool;
	public static var DOWN_ALT:Bool;
	public static var LEFT_ALT:Bool;
	public static var RIGHT_ALT:Bool;
	public static var JUMP_ALT:Bool;
	public static var PUNCH_ALT:Bool;
	public static var SELECT_ALT:Bool;
	public static var BACK_ALT:Bool;
	public static var PAUSE_ALT:Bool;

	// Detección de Gamepad
	public static var isGamepadConnected:Bool;

	public static function init()
	{
		#if android
		FlxG.android.preventDefaultKeys = [FlxAndroidKey.BACK];
		#else
		FlxG.sound.volumeDownKeys = [NUMPADMINUS];
		FlxG.sound.volumeUpKeys = [NUMPADPLUS];
		FlxG.sound.muteKeys = [NUMPADZERO];
		#end
		trace("Input initialized!");
	}

	public static function update()
	{
		#if android
		var firstTouch = FlxG.touches.getFirst();
		SELECT = firstTouch != null ? firstTouch.justPressed : false;
		PAUSE = FlxG.android.justPressed.BACK;
		BACK = FlxG.android.justPressed.BACK;
		#else
		UP = FlxG.keys.justPressed.UP;
		DOWN = FlxG.keys.justPressed.DOWN;
		LEFT = FlxG.keys.pressed.LEFT;
		RIGHT = FlxG.keys.pressed.RIGHT;
		JUMP = FlxG.keys.anyPressed([FlxKey.UP, Z]);
		PUNCH = FlxG.keys.anyJustPressed([C, SPACE]);
		SELECT = FlxG.keys.justPressed.ENTER;
		BACK = FlxG.keys.justPressed.ESCAPE;
		PAUSE = FlxG.keys.justPressed.ENTER;
		#end

		#if desktop
		// Solamente tengo un humilde joystick genérico, así que trataré mostrar lo mejor que pueda los controles.
		// Al parecer, en HaxeFlixel viene con el esquema del Xbox.
		var gamepad = FlxG.gamepads.lastActive;
		if (gamepad != null)
		{
			isGamepadConnected = true;
			UP_ALT = gamepad.justPressed.DPAD_UP;
			DOWN_ALT = gamepad.justPressed.DPAD_DOWN;
			LEFT_ALT = gamepad.analog.value.LEFT_STICK_X < 0 || gamepad.pressed.DPAD_LEFT;
			RIGHT_ALT = gamepad.analog.value.LEFT_STICK_X > 0 || gamepad.pressed.DPAD_RIGHT;
			JUMP_ALT = gamepad.pressed.A; // Xbox -> A | Play -> Cruz
			PUNCH_ALT = gamepad.justPressed.B; // Xbox -> B | Play -> Cuadrado
			SELECT_ALT = gamepad.justPressed.A;
			BACK_ALT = gamepad.justPressed.BACK; // Xbox -> Back | Play -> Select
			PAUSE_ALT = gamepad.justPressed.START;
		}
		else
			isGamepadConnected = false;
		#end
	}
}
