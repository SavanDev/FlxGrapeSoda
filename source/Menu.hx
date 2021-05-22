package;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxTween;

class Menu extends FlxGroup
{
	var cursor:FlxBitmapText;
	var options:Array<{text:String, event:Menu->Void}>;
	var optionsText:FlxTypedGroup<FlxBitmapText>;

	var selectedIndex:Int = 0;

	// Bueno... ahora se puede reutilizar
	public function new(x:Float = 0, y:Float = 0, items:Array<{text:String, event:Menu->Void}>)
	{
		super();
		optionsText = new FlxTypedGroup<FlxBitmapText>();
		options = items;

		#if !android
		cursor = new FlxBitmapText(Fonts.TOY);
		cursor.setPosition(x, y - 5);
		cursor.text = ">";
		add(cursor);
		FlxTween.num(x, x + 2, .25, {type: PINGPONG}, (v:Float) -> cursor.x = v);
		#end

		for (i in 0...items.length)
		{
			#if android
			var item = new FlxBitmapText(Fonts.DEFAULT);
			item.setPosition(x, y + (i * 12));
			#else
			var item = new FlxBitmapText(Fonts.TOY);
			item.setPosition(x + 10, y - 5 + (i * 10));
			#end
			item.text = items[i].text;
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
					options[selectedIndex].event(this);
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
			options[selectedIndex].event(this);
		#end
	}
}
