package;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxTween;
import openfl.utils.Dictionary;

class Menu extends FlxGroup
{
	#if (web || mobile)
	var options = ['Start', 'Donate'];
	#elseif editor
	var options = ['Start', 'Donate', 'Map Editor', 'Exit'];
	#else
	var options = ['Start', 'Donate', 'Exit'];
	#end
	var cursor:FlxBitmapText;
	var optionsText:FlxTypedGroup<FlxBitmapText>;
	var optionsEvent:Dictionary<Int, Void->Void>;

	var selectedIndex:Int = 0;

	public function new(x:Float = 0, y:Float = 0)
	{
		super();
		optionsText = new FlxTypedGroup<FlxBitmapText>();
		optionsEvent = new Dictionary<Int, Void->Void>();

		#if !android
		cursor = new FlxBitmapText();
		cursor.setPosition(x, y);
		cursor.text = ">";
		add(cursor);
		FlxTween.num(x, x + 2, .25, {type: PINGPONG}, (v:Float) -> cursor.x = v);
		#end

		for (i in 0...options.length)
		{
			var item = new FlxBitmapText();
			item.setPosition(x + 10, y + (i * 10));
			item.text = options[i];
			item.useTextColor = true;
			optionsText.add(item);
		}
		add(optionsText);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		#if android
		var touch = FlxG.touches.getFirst();
		if (touch != null)
		{
			for (i in 0...optionsText.length)
			{
				if (touch.getPosition().inRect(optionsText.members[i].getHitbox()))
				{
					selectedIndex = i;
					optionsEvent.get(selectedIndex)();
				}
			}
		}
		#else
		if (Input.UP || Input.UP_ALT)
		{
			selectedIndex--;
			if (selectedIndex < 0)
				selectedIndex = optionsText.length - 1;

			cursor.y = optionsText.members[selectedIndex].y;
			FlxG.sound.play(Paths.getSound("blip"));
		}
		if (Input.DOWN || Input.DOWN_ALT)
		{
			selectedIndex++;
			if (selectedIndex >= optionsText.length)
				selectedIndex = 0;

			cursor.y = optionsText.members[selectedIndex].y;
			FlxG.sound.play(Paths.getSound("blip"));
		}
		if (Input.SELECT || Input.SELECT_ALT)
		{
			if (optionsEvent.exists(selectedIndex))
			{
				var event = optionsEvent.get(selectedIndex);
				event();
			}
		}
		#end
	}

	public function addEvent(_index:Int, _event:Void->Void)
	{
		optionsEvent.set(_index, _event);
	}
}
