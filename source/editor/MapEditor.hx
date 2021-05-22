package editor;

import Paths.DirTarget;
#if editor
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxInputText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxRect;
import flixel.text.FlxBitmapText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

class MapEditor extends FlxState
{
	static inline var TILE_WIDTH:Int = 12;
	static inline var TILE_HEIGHT:Int = 12;

	var MAP_WIDTH:Int = 8;
	var MAP_HEIGHT:Int = 8;

	var _levelMap:FlxTypedGroup<FlxTilemap>;
	var _highlightBox:FlxSprite;
	var _highlightBorders:FlxSprite;
	var _tileSelectedSprite:FlxSprite;

	var _sprLayer2:FlxSprite;
	var _sprLayer1:FlxSprite;
	var _sprLayer0:FlxSprite;

	var _selectedTile(default, set):Int = 1;
	var _selectedLayer(default, set):Int = 2;
	var _offsetTiles(default, set):Int = 0;
	var _offsetTilesY(default, set):Int = 0;
	var _textPos:FlxBitmapText;

	var _inputMapX:FlxInputText;
	var _inputMapY:FlxInputText;

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
		_selectedTile = 1;
		setLayerTilePreview();
		return _selectedLayer;
	}

	function set__offsetTiles(newOffset)
	{
		_levelMap.forEach((tilemap) -> tilemap.x = newOffset * 12);
		_highlightBorders.x = newOffset * 12;
		return _offsetTiles = newOffset;
	}

	function set__offsetTilesY(newOffset)
	{
		_levelMap.forEach((tilemap) -> tilemap.y = newOffset * 12);
		_highlightBorders.y = newOffset * 12;
		return _offsetTilesY = newOffset;
	}

	function setLayerTilePreview()
	{
		var path:String = null;

		switch (_selectedLayer)
		{
			case 0:
				path = Paths.getImage("tilemaps/backgrass");
				_sprLayer2.animation.frameIndex = 1;
				_sprLayer1.animation.frameIndex = 1;
				_sprLayer0.animation.frameIndex = 0;
			case 1:
				path = Paths.getImage("tilemaps/objects");
				_sprLayer2.animation.frameIndex = 1;
				_sprLayer1.animation.frameIndex = 0;
				_sprLayer0.animation.frameIndex = 1;
			case 2:
				path = Paths.getImage("tilemaps/grass");
				_sprLayer2.animation.frameIndex = 0;
				_sprLayer1.animation.frameIndex = 1;
				_sprLayer0.animation.frameIndex = 1;
		}

		_tileSelectedSprite.loadGraphic(path, true, 12, 12);
		_tileSelectedSprite.animation.frameIndex = _selectedLayer == 2 ? 0 : _selectedTile;
	}

	function createMap()
	{
		var testMap = [for (i in 0...MAP_WIDTH * MAP_HEIGHT) 0];

		if (_levelMap != null)
		{
			_levelMap.forEach((tilemap) -> tilemap.destroy());
			_levelMap.clear();
			_highlightBorders.makeGraphic(MAP_WIDTH * 12, MAP_HEIGHT * 12, FlxColor.TRANSPARENT);
			FlxSpriteUtil.drawRect(_highlightBorders, 0, 0, MAP_WIDTH * 12, MAP_HEIGHT * 12, FlxColor.TRANSPARENT, {color: FlxColor.RED});
		}
		else
		{
			_levelMap = new FlxTypedGroup<FlxTilemap>();
			add(_levelMap);
		}

		var layer2 = new FlxTilemap();
		layer2.loadMapFromArray(testMap, MAP_WIDTH, MAP_HEIGHT, Paths.getImage("tilemaps/backgrass"), TILE_WIDTH, TILE_HEIGHT);
		_levelMap.add(layer2);

		var layer1 = new FlxTilemap();
		layer1.loadMapFromArray(testMap, MAP_WIDTH, MAP_HEIGHT, Paths.getImage("tilemaps/objects"), TILE_WIDTH, TILE_HEIGHT);
		_levelMap.add(layer1);

		var layer0 = new FlxTilemap();
		layer0.loadMapFromArray(testMap, MAP_WIDTH, MAP_HEIGHT, Paths.getImage("tilemaps/grass"), TILE_WIDTH, TILE_HEIGHT, FULL);
		_levelMap.add(layer0);

		_offsetTiles = 0;
		_offsetTilesY = 0;
	}

	// FlxState functions!
	override public function create()
	{
		super.create();
		FlxG.mouse.visible = true;
		FlxG.sound.music.stop();
		var uiCamera:FlxCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		uiCamera.bgColor = FlxColor.TRANSPARENT;

		// UI stuff
		_highlightBorders = new FlxSprite(0, 0);
		_highlightBorders.makeGraphic(MAP_WIDTH * 12, MAP_HEIGHT * 12, FlxColor.TRANSPARENT);
		add(_highlightBorders);
		FlxSpriteUtil.drawRect(_highlightBorders, 0, 0, MAP_WIDTH * 12, MAP_HEIGHT * 12, FlxColor.TRANSPARENT, {color: FlxColor.RED});

		var backgroundBorder = new FlxSprite(0, FlxG.height - 16);
		backgroundBorder.makeGraphic(FlxG.width, 16, 0xFF0163C6);
		add(backgroundBorder);

		_tileSelectedSprite = new FlxSprite(2, FlxG.height - 14);
		_tileSelectedSprite.loadGraphic(Paths.getImage("tilemaps/grass"), true, 12, 12);
		add(_tileSelectedSprite);

		_textPos = new FlxBitmapText();
		_textPos.setPosition(16, FlxG.height - 14);
		_textPos.text = "X: 0\nY: 0";
		add(_textPos);

		_sprLayer2 = new FlxSprite(FlxG.width - 24, FlxG.height - 25);
		_sprLayer2.loadGraphic(Paths.getImage("layer0", DirTarget.Editor), true, 8, 9);
		add(_sprLayer2);

		_sprLayer1 = new FlxSprite(FlxG.width - 16, FlxG.height - 25);
		_sprLayer1.loadGraphic(Paths.getImage("layer1", DirTarget.Editor), true, 8, 9);
		_sprLayer1.animation.frameIndex = 1;
		add(_sprLayer1);

		_sprLayer0 = new FlxSprite(FlxG.width - 8, FlxG.height - 25);
		_sprLayer0.loadGraphic(Paths.getImage("layer2", DirTarget.Editor), true, 8, 9);
		_sprLayer0.animation.frameIndex = 1;
		add(_sprLayer0);

		var backgroundInput = new FlxSprite(FlxG.width - 40, 0);
		backgroundInput.makeGraphic(40, 35, 0xFF0163C6);
		add(backgroundInput);

		_inputMapX = new FlxInputText(FlxG.width - 35, 5, 25);
		_inputMapX.setFormat("assets/editor/fonts/Toy.ttf", 8, FlxColor.BLACK);
		add(_inputMapX);

		_inputMapY = new FlxInputText(FlxG.width - 35, 20, 25);
		_inputMapY.setFormat("assets/editor/fonts/Toy.ttf", 8, FlxColor.BLACK);
		add(_inputMapY);

		_inputMapX.text = Std.string(MAP_WIDTH);
		_inputMapY.text = Std.string(MAP_HEIGHT);

		_inputMapX.callback = _inputMapY.callback = (text, action) ->

		{
			if (action == FlxInputText.ENTER_ACTION)
			{
				MAP_WIDTH = Std.parseInt(_inputMapX.text);
				MAP_HEIGHT = Std.parseInt(_inputMapY.text);
				createMap();
			}
		};

		var mapEditorText = new FlxBitmapText(Fonts.TOY);
		mapEditorText.text = "MAP EDITOR";
		mapEditorText.x = FlxG.width - mapEditorText.width - 2;
		mapEditorText.y = FlxG.height - mapEditorText.height - 2;
		add(mapEditorText);

		// Map stuff
		createMap();

		_highlightBox = new FlxSprite(0, 0);
		_highlightBox.makeGraphic(TILE_WIDTH, TILE_HEIGHT, 0x99FF0000);
		add(_highlightBox);

		// Configurar cámaras
		FlxG.cameras.add(uiCamera, false);
		backgroundBorder.cameras = [uiCamera];
		_tileSelectedSprite.cameras = [uiCamera];
		_textPos.cameras = [uiCamera];
		_sprLayer2.cameras = [uiCamera];
		_sprLayer1.cameras = [uiCamera];
		_sprLayer0.cameras = [uiCamera];
		_inputMapX.cameras = [uiCamera];
		_inputMapY.cameras = [uiCamera];
		backgroundInput.cameras = [uiCamera];
		mapEditorText.cameras = [uiCamera];

		FlxG.camera.bgColor = FlxColor.BLACK;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// Selector y función para colocar y sacar
		var mouseX = Std.int(FlxG.mouse.x / TILE_WIDTH) - _offsetTiles;
		var mouseY = Std.int(FlxG.mouse.y / TILE_HEIGHT) - _offsetTilesY;
		var levelSize = new FlxRect(_offsetTiles * 12, _offsetTilesY * 12, (MAP_WIDTH * 12) - 1, (MAP_HEIGHT * 12) - 1);

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

		// Ajustes para el "offset"
		if (FlxG.keys.pressed.RIGHT)
			_offsetTiles++;

		if (FlxG.keys.pressed.LEFT)
			_offsetTiles--;

		if (FlxG.keys.pressed.UP)
			_offsetTilesY++;

		if (FlxG.keys.pressed.DOWN)
			_offsetTilesY--;

		// Zoom
		if (FlxG.keys.justPressed.PAGEUP)
			FlxG.camera.zoom += .25;

		if (FlxG.keys.justPressed.PAGEDOWN)
			FlxG.camera.zoom -= .25;

		// Cambiar "tile" seleccionado
		if (_selectedLayer != 2)
		{
			if (FlxG.mouse.wheel < 0 && _selectedTile < _tileSelectedSprite.animation.frames - 1)
				_selectedTile++;

			if (FlxG.mouse.wheel > 0 && _selectedTile > 1)
				_selectedTile--;
		}

		// Cambiar capa
		if (FlxG.keys.justPressed.ONE)
			_selectedLayer = 2;

		if (FlxG.keys.justPressed.TWO)
			_selectedLayer = 1;

		if (FlxG.keys.justPressed.THREE)
			_selectedLayer = 0;

		// Salir del editor
		if (FlxG.keys.justPressed.ESCAPE && !_exited)
		{
			_exited = true;
			FlxG.camera.fade(() -> FlxG.switchState(new MenuState()));
		}

		_textPos.text = 'X: $mouseX\nY: $mouseY';
	}
}
#end
