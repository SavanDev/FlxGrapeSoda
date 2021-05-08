package;

import flixel.ui.FlxVirtualPad;

class MobilePad extends FlxVirtualPad
{
	public function new()
	{
		super(FlxDPadMode.LEFT_RIGHT, FlxActionMode.A_B);
		buttonLeft.loadGraphic("misc/mobile/mobile_left.png", true, 32, 32);
		buttonRight.loadGraphic("misc/mobile/mobile_right.png", true, 32, 32);
		buttonA.loadGraphic("misc/mobile/mobile_up.png", true, 32, 32);
		buttonB.loadGraphic("misc/mobile/mobile_punch.png", true, 32, 32);

		buttonLeft.updateHitbox();
		buttonRight.updateHitbox();
		buttonA.updateHitbox();
		buttonB.updateHitbox();

		buttonLeft.setPosition(7, 105);
		buttonRight.setPosition(48, 105);
		buttonA.setPosition(211, 105);
		buttonB.setPosition(170, 105);
	}
}
