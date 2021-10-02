package util;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.utils.Dictionary;

typedef MenuItem =
{
	var text:String;
	var event:Menu->Void;
};

class Menu extends FlxGroup
{
	public var accent:FlxColor = 0xFF5B315B;

	#if !mobile
	var cursor:FlxBitmapText;
	#end

	var options:Dictionary<String, Array<MenuItem>>;
	var optionsText:FlxTypedGroup<FlxBitmapText>;

	var selectedIndex:Int = 0;
	var actualPage:String;

	var x:Float;
	var y:Float;

	public function new(_x:Float = 0, _y:Float = 0)
	{
		super();
		options = new Dictionary<String, Array<MenuItem>>();
		optionsText = new FlxTypedGroup<FlxBitmapText>();
		x = _x;
		y = _y;

		#if !mobile
		cursor = new FlxBitmapText(Fonts.TOY);
		cursor.setPosition(x, y - 5);
		cursor.text = ">";
		cursor.setBorderStyle(FlxTextBorderStyle.OUTLINE, accent);
		add(cursor);
		FlxTween.num(x, x + 2, .25, {type: PINGPONG}, (v:Float) -> cursor.x = v);
		#end

		add(optionsText);
	}

	public function addPage(name:String, items:Array<MenuItem>)
	{
		options.set(name, items);
	}

	public function gotoPage(name:String)
	{
		if (options.exists(name))
		{
			actualPage = name;
			selectedIndex = 0;
			drawPage();
		}
		else
			trace("Page not exists!");
	}

	function drawPage()
	{
		optionsText.forEach((item) -> item.destroy());
		optionsText.clear();

		#if !mobile
		cursor.setPosition(x, y - 5);
		#end

		var items = options.get(actualPage);

		for (i in 0...items.length)
		{
			#if mobile
			var item = new FlxBitmapText(Fonts.DEFAULT);
			item.setPosition(x, y + (i * 12));
			#else
			var item = new FlxBitmapText(Fonts.TOY);
			item.setPosition(x + 10, y - 5 + (i * 10));
			#end

			item.text = items[i].text;
			item.useTextColor = true;
			item.setBorderStyle(FlxTextBorderStyle.OUTLINE, accent);

			optionsText.add(item);
		}
	}

	function getOption():FlxBitmapText
	{
		return optionsText.members[selectedIndex];
	}

	public function changeOptionName(newName:String)
	{
		options.get(actualPage)[selectedIndex].text = newName;
		getOption().text = newName;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		#if mobile
		var touch = FlxG.touches.getFirst();
		if (touch != null)
		{
			for (i in 0...optionsText.length)
			{
				if (touch.getPosition().inRect(optionsText.members[i].getHitbox()))
				{
					selectedIndex = i;
					options.get(actualPage)[selectedIndex].event(this);
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
			options.get(actualPage)[selectedIndex].event(this);
		#end
	}
}
