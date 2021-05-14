#if editor
package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxRect;
import flixel.text.FlxBitmapText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;

class MapEditorState extends FlxState
{
	static inline var TILE_WIDTH:Int = 12;
	static inline var TILE_HEIGHT:Int = 12;

	var MAP_WIDTH:Int = 10;
	var MAP_HEIGHT:Int = 10;

	var _levelMap:FlxTypedGroup<FlxTilemap>;
	var _highlightBox:FlxSprite;
	var _tileSelectedSprite:FlxSprite;

	var _sprLayerFront:FlxSprite;
	var _sprLayerBack:FlxSprite;

	var _selectedTile(default, set):Int = 1;
	var _selectedLayer(default, set):Int = 1;
	var _offsetTiles(default, set):Int = 0;
	var _textPos:FlxBitmapText;

	var _exited:Bool = false;

	// Map Editor functions!
	function set__selectedTile(newTile)
	{
		_tileSelectedSprite.animation.frameIndex = newTile;
		return _selectedTile = newTile;
	}

	function set__selectedLayer(newLayer)
	{
		_selectedLayer = newLayer;
		setLayerTilePreview();
		return _selectedLayer;
	}

	function set__offsetTiles(newOffset)
	{
		_levelMap.forEach((tilemap) -> tilemap.x = newOffset * 12);
		return _offsetTiles = newOffset;
	}

	function setLayerTilePreview()
	{
		var path:String = null;

		switch (_selectedLayer)
		{
			case 0:
				path = Paths.getImage("backTileMap");
				_sprLayerFront.animation.frameIndex = 1;
				_sprLayerBack.animation.frameIndex = 0;
			case 1:
				path = Paths.getImage("tileMap");
				_sprLayerFront.animation.frameIndex = 0;
				_sprLayerBack.animation.frameIndex = 1;
		}

		_tileSelectedSprite.loadGraphic(path, true, 12, 12);
		_tileSelectedSprite.animation.frameIndex = _selectedTile;
	}

	// FlxState functions!
	override public function create()
	{
		super.create();
		bgColor = FlxColor.BLACK;
		FlxG.sound.music.stop();

		var testMap = [for (i in 0...MAP_WIDTH * MAP_HEIGHT) 0];

		_levelMap = new FlxTypedGroup<FlxTilemap>();
		add(_levelMap);

		var backTilemap = new FlxTilemap();
		backTilemap.loadMapFromArray(testMap, MAP_WIDTH, MAP_HEIGHT, Paths.getImage("backTileMap"), TILE_WIDTH, TILE_HEIGHT);
		_levelMap.add(backTilemap);

		var tileMap = new FlxTilemap();
		tileMap.loadMapFromArray(testMap, MAP_WIDTH, MAP_HEIGHT, Paths.getImage("tileMap"), TILE_WIDTH, TILE_HEIGHT);
		_levelMap.add(tileMap);

		var backgroundBorder = new FlxSprite(0, FlxG.height - 16);

		backgroundBorder.makeGraphic(FlxG.width, 16, 0xFF0163C6);
		add(backgroundBorder);

		_highlightBox = new FlxSprite(0, 0);
		_highlightBox.makeGraphic(TILE_WIDTH, TILE_HEIGHT, 0x99FF0000);
		add(_highlightBox);

		_tileSelectedSprite = new FlxSprite(2, FlxG.height - 14);
		_tileSelectedSprite.loadGraphic(Paths.getImage("tileMap"), true, 12, 12);
		_tileSelectedSprite.animation.frameIndex = _selectedTile;
		add(_tileSelectedSprite);

		_textPos = new FlxBitmapText();
		_textPos.setPosition(16, FlxG.height - 14);
		_textPos.text = "X: 0\nY: 0";
		add(_textPos);

		_sprLayerFront = new FlxSprite(FlxG.width - 16, FlxG.height - 24);
		_sprLayerFront.loadGraphic(Paths.getImage("editor/layer0"), true, 8, 8);
		add(_sprLayerFront);

		_sprLayerBack = new FlxSprite(FlxG.width - 8, FlxG.height - 24);
		_sprLayerBack.loadGraphic(Paths.getImage("editor/layer1"), true, 8, 8);
		_sprLayerBack.animation.frameIndex = 1;
		add(_sprLayerBack);

		var mapEditorText = new FlxBitmapText();
		mapEditorText.text = "MAP EDITOR";
		mapEditorText.x = FlxG.width - mapEditorText.width - 2;
		mapEditorText.y = FlxG.height - mapEditorText.height - 2;
		add(mapEditorText);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		var mouseX = Std.int(FlxG.mouse.x / TILE_WIDTH) - _offsetTiles;
		var mouseY = Std.int(FlxG.mouse.y / TILE_HEIGHT);
		var levelSize = new FlxRect(_offsetTiles * 12, 0, (MAP_WIDTH * 12) - 1, (MAP_HEIGHT * 12) - 1);

		if (FlxG.mouse.getPosition().inRect(levelSize))
		{
			_highlightBox.x = Math.floor(FlxG.mouse.x / TILE_WIDTH) * TILE_WIDTH;
			_highlightBox.y = Math.floor(FlxG.mouse.y / TILE_HEIGHT) * TILE_HEIGHT;
			_highlightBox.visible = true;
		}
		else
			_highlightBox.visible = false;

		if (FlxG.mouse.pressed && _highlightBox.visible)
			_levelMap.members[_selectedLayer].setTile(mouseX, mouseY, _selectedTile);
		if (FlxG.mouse.pressedRight && _highlightBox.visible)
			_levelMap.members[_selectedLayer].setTile(mouseX, mouseY, 0);

		if (FlxG.keys.justPressed.RIGHT)
			_offsetTiles++;

		if (FlxG.keys.justPressed.LEFT)
			_offsetTiles--;

		if ((FlxG.keys.justPressed.UP || FlxG.mouse.wheel < 0) && _selectedTile < 24)
			_selectedTile++;

		if ((FlxG.keys.justPressed.DOWN || FlxG.mouse.wheel > 0) && _selectedTile > 1)
			_selectedTile--;

		if (FlxG.keys.justPressed.ONE)
			_selectedLayer = 1;

		if (FlxG.keys.justPressed.TWO)
			_selectedLayer = 0;

		if (FlxG.keys.justPressed.ESCAPE && !_exited)
		{
			_exited = true;
			FlxG.camera.fade(() -> FlxG.switchState(new MenuState()));
		}

		_textPos.text = 'X: $mouseX\nY: $mouseY';
	}
}
#end
