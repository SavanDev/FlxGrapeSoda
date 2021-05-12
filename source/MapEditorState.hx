package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxBitmapText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;

class MapEditorState extends FlxState
{
	static inline var TILE_WIDTH:Int = 12;
	static inline var TILE_HEIGHT:Int = 12;

	var _levelMap:FlxTilemap;
	var _highlightBox:FlxSprite;
	var _tileSelectedSprite:FlxSprite;

	var _selectedTile:Int = 1;
	var _offsetTiles:Int = 0;
	var _textPos:FlxBitmapText;

	var _outsideMap:Bool = false;

	override public function create()
	{
		super.create();
		bgColor = FlxColor.BLACK;
		FlxG.sound.music.stop();

		var testMap = [for (i in 0...100) 0];

		_levelMap = new FlxTilemap();
		_levelMap.loadMapFromArray(testMap, 10, 10, Paths.getImage("tileMap"), TILE_WIDTH, TILE_HEIGHT);
		add(_levelMap);

		_highlightBox = new FlxSprite(0, 0);
		_highlightBox.makeGraphic(TILE_WIDTH, TILE_HEIGHT, 0x55FF0000);
		add(_highlightBox);

		_tileSelectedSprite = new FlxSprite(0, FlxG.height - 12);
		_tileSelectedSprite.loadGraphic(Paths.getImage("tileMap"), true, 12, 12);
		_tileSelectedSprite.animation.frameIndex = 1;
		add(_tileSelectedSprite);

		_textPos = new FlxBitmapText(Fonts.DEFAULT);
		_textPos.setPosition(16, FlxG.height - 20);
		_textPos.text = "X: 0\nY: 0";
		add(_textPos);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		var mouseX = Std.int(FlxG.mouse.x / TILE_WIDTH) - _offsetTiles;
		var mouseY = Std.int(FlxG.mouse.y / TILE_HEIGHT);

		if (FlxG.mouse.getPosition().inRect(_levelMap.getHitbox()))
		{
			_highlightBox.x = Math.floor(FlxG.mouse.x / TILE_WIDTH) * TILE_WIDTH;
			_highlightBox.y = Math.floor(FlxG.mouse.y / TILE_HEIGHT) * TILE_HEIGHT;
			_outsideMap = false;
		}
		else
			_outsideMap = true;

		if (FlxG.mouse.pressed)
			_levelMap.setTile(mouseX, mouseY, _selectedTile);
		if (FlxG.mouse.pressedRight)
			_levelMap.setTile(mouseX, mouseY, 0);

		if (FlxG.keys.justPressed.RIGHT)
		{
			_offsetTiles++;
			_levelMap.x = _offsetTiles * 12;
		}

		if (FlxG.keys.justPressed.LEFT)
		{
			_offsetTiles--;
			_levelMap.x = _offsetTiles * 12;
		}

		if ((FlxG.keys.justPressed.UP || FlxG.mouse.wheel > 0) && _selectedTile < 24)
		{
			_selectedTile++;
			_tileSelectedSprite.animation.frameIndex = _selectedTile;
		}

		if ((FlxG.keys.justPressed.DOWN || FlxG.mouse.wheel < 0) && _selectedTile > 1)
		{
			_selectedTile--;
			_tileSelectedSprite.animation.frameIndex = _selectedTile;
		}

		_textPos.text = 'X: $mouseX\nY: $mouseY';
	}
}
