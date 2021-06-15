package misc;

import Paths.DirTarget;
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

		// Callbacks
		btnLeft.onDown.callback = () -> Input.LEFT = true;
		btnRight.onDown.callback = () -> Input.RIGHT = true;
		btnJump.onDown.callback = () -> Input.JUMP = true;
		btnPunch.onDown.callback = () -> Input.PUNCH = true;

		btnLeft.onOut.callback = () -> Input.LEFT = false;
		btnRight.onOut.callback = () -> Input.RIGHT = false;
		btnJump.onOut.callback = () -> Input.JUMP = false;
		btnPunch.onOut.callback = () -> Input.PUNCH = false;

		btnLeft.loadGraphic(Paths.getImage("mobile_left", DirTarget.Mobile), true, 32, 32);
		btnRight.loadGraphic(Paths.getImage("mobile_right", DirTarget.Mobile), true, 32, 32);
		btnJump.loadGraphic(Paths.getImage("mobile_up", DirTarget.Mobile), true, 32, 32);
		btnPunch.loadGraphic(Paths.getImage("mobile_punch", DirTarget.Mobile), true, 32, 32);

		add(btnLeft);
		add(btnRight);
		add(btnJump);
		add(btnPunch);
	}
}
