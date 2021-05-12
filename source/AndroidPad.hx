package;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.ui.FlxButton;

class AndroidPad extends FlxTypedGroup<FlxButton>
{
	var btnLeft:FlxButton;
	var btnRight:FlxButton;
	var btnJump:FlxButton;
	var btnPunch:FlxButton;

	public function new()
	{
		super();

		// Las posiciones se sacaron a partir de la imagen de referencia.
		btnLeft = new FlxButton(7, 105);
		btnRight = new FlxButton(48, 105);
		btnJump = new FlxButton(211, 105);
		btnPunch = new FlxButton(170, 105);

		// TODO: Por ahora sirve xD
		btnLeft.onDown.callback = () -> Input.LEFT = true;
		btnRight.onDown.callback = () -> Input.RIGHT = true;
		btnJump.onDown.callback = () -> Input.JUMP = true;
		btnPunch.onDown.callback = () -> Input.PUNCH = true;

		btnLeft.onUp.callback = () -> Input.LEFT = false;
		btnRight.onUp.callback = () -> Input.RIGHT = false;
		btnJump.onUp.callback = () -> Input.JUMP = false;
		btnPunch.onUp.callback = () -> Input.PUNCH = false;

		btnLeft.loadGraphic("misc/mobile/mobile_left.png", true, 32, 32);
		btnRight.loadGraphic("misc/mobile/mobile_right.png", true, 32, 32);
		btnJump.loadGraphic("misc/mobile/mobile_up.png", true, 32, 32);
		btnPunch.loadGraphic("misc/mobile/mobile_punch.png", true, 32, 32);

		add(btnLeft);
		add(btnRight);
		add(btnJump);
		add(btnPunch);
	}
}