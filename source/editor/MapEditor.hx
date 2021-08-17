package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxRect;
import flixel.text.FlxBitmapText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

enum EditorState
{
	Tilemap;
	Entity;
	Playing;
}

class MapEditor extends FlxState
{
	static inline var TILE_WIDTH:Int = 12;
	static inline var TILE_HEIGHT:Int = 12;

	public var MAP_WIDTH:Int = 10;
	public var MAP_HEIGHT:Int = 10;

	var levelMap:FlxTypedGroup<FlxTilemap>;
	var highlightBox:FlxSprite;
	var highlightBorders:FlxSprite;
	var tileSelectedSprite:FlxSprite;

	var sprLayer2:FlxSprite;
	var sprLayer1:FlxSprite;
	var sprLayer0:FlxSprite;

	var selectedTile(default, set):Int = 1;
	var selectedLayer(default, set):Int = 2;
	var offsetTiles(default, set):Int = 0;
	var offsetTilesY(default, set):Int = 0;
	var textPos:FlxBitmapText;

	var exited:Bool = false;
	var editorState:EditorState = Tilemap;

	// Map Editor functions!
	function set_selectedTile(_newTile)
	{
		tileSelectedSprite.animation.frameIndex = _newTile;
		return selectedTile = _newTile;
	}

	function set_selectedLayer(_newLayer)
	{
		selectedLayer = _newLayer;
		selectedTile = 1;
		setLayerTilePreview();
		return selectedLayer;
	}

	function set_offsetTiles(_newOffset)
	{
		levelMap.forEach((tilemap) -> tilemap.x = _newOffset * 12);
		highlightBorders.x = _newOffset * 12;
		return offsetTiles = _newOffset;
	}

	function set_offsetTilesY(_newOffset)
	{
		levelMap.forEach((tilemap) -> tilemap.y = _newOffset * 12);
		highlightBorders.y = _newOffset * 12;
		return offsetTilesY = _newOffset;
	}

	function setLayerTilePreview()
	{
		var path:String = null;

		switch (selectedLayer)
		{
			case 0:
				path = Paths.getImage("tilemaps/backgrass");
				sprLayer2.animation.frameIndex = 1;
				sprLayer1.animation.frameIndex = 1;
				sprLayer0.animation.frameIndex = 0;
			case 1:
				path = Paths.getImage("tilemaps/objects");
				sprLayer2.animation.frameIndex = 1;
				sprLayer1.animation.frameIndex = 0;
				sprLayer0.animation.frameIndex = 1;
			case 2:
				path = Paths.getImage("tilemaps/grass");
				sprLayer2.animation.frameIndex = 0;
				sprLayer1.animation.frameIndex = 1;
				sprLayer0.animation.frameIndex = 1;
		}

		tileSelectedSprite.loadGraphic(path, true, 12, 12);
		tileSelectedSprite.animation.frameIndex = selectedLayer == 2 ? 0 : selectedTile;
	}

	public function createMap()
	{
		var testMap = [for (i in 0...MAP_WIDTH * MAP_HEIGHT) 0];

		if (levelMap != null)
		{
			levelMap.forEach((tilemap) -> tilemap.destroy());
			levelMap.clear();
			highlightBorders.makeGraphic(MAP_WIDTH * 12, MAP_HEIGHT * 12, FlxColor.TRANSPARENT);
			FlxSpriteUtil.drawRect(highlightBorders, 0, 0, MAP_WIDTH * 12, MAP_HEIGHT * 12, FlxColor.TRANSPARENT, {color: FlxColor.RED});
		}
		else
		{
			levelMap = new FlxTypedGroup<FlxTilemap>();
			add(levelMap);
		}

		var layer2 = new FlxTilemap();
		layer2.loadMapFromArray(testMap, MAP_WIDTH, MAP_HEIGHT, Paths.getImage("tilemaps/backgrass"), TILE_WIDTH, TILE_HEIGHT);
		levelMap.add(layer2);

		var layer1 = new FlxTilemap();
		layer1.loadMapFromArray(testMap, MAP_WIDTH, MAP_HEIGHT, Paths.getImage("tilemaps/objects"), TILE_WIDTH, TILE_HEIGHT);
		levelMap.add(layer1);

		var layer0 = new FlxTilemap();
		layer0.loadMapFromArray(testMap, MAP_WIDTH, MAP_HEIGHT, Paths.getImage("tilemaps/grass"), TILE_WIDTH, TILE_HEIGHT, FULL);
		levelMap.add(layer0);

		offsetTiles = 0;
		offsetTilesY = 0;
	}

	function onEditorUpdate()
	{
		// Selector y función para colocar y sacar
		var mouseX = Std.int(FlxG.mouse.x / TILE_WIDTH) - offsetTiles;
		var mouseY = Std.int(FlxG.mouse.y / TILE_HEIGHT) - offsetTilesY;
		var levelSize = new FlxRect(offsetTiles * 12, offsetTilesY * 12, (MAP_WIDTH * 12) - 1, (MAP_HEIGHT * 12) - 1);

		if (FlxG.mouse.getPosition().inRect(levelSize))
		{
			highlightBox.x = Math.floor(FlxG.mouse.x / TILE_WIDTH) * TILE_WIDTH;
			highlightBox.y = Math.floor(FlxG.mouse.y / TILE_HEIGHT) * TILE_HEIGHT;
			highlightBox.visible = true;
		}
		else
			highlightBox.visible = false;

		if (FlxG.mouse.pressed && highlightBox.visible)
			levelMap.members[selectedLayer].setTile(mouseX, mouseY, selectedTile);
		if (FlxG.mouse.pressedRight && highlightBox.visible)
			levelMap.members[selectedLayer].setTile(mouseX, mouseY, 0);

		// Ajustes para el "offset"
		if (FlxG.keys.pressed.RIGHT)
			offsetTiles++;

		if (FlxG.keys.pressed.LEFT)
			offsetTiles--;

		if (FlxG.keys.pressed.UP)
			offsetTilesY++;

		if (FlxG.keys.pressed.DOWN)
			offsetTilesY--;

		// Zoom
		if (FlxG.keys.justPressed.PAGEUP)
			FlxG.camera.zoom += .25;

		if (FlxG.keys.justPressed.PAGEDOWN)
			FlxG.camera.zoom -= .25;

		// Cambiar "tile" seleccionado
		if (selectedLayer != 2)
		{
			if (FlxG.mouse.wheel < 0 && selectedTile < tileSelectedSprite.animation.frames - 1)
				selectedTile++;

			if (FlxG.mouse.wheel > 0 && selectedTile > 1)
				selectedTile--;
		}

		// Cambiar capa
		if (FlxG.keys.justPressed.ONE)
			selectedLayer = 2;

		if (FlxG.keys.justPressed.TWO)
			selectedLayer = 1;

		if (FlxG.keys.justPressed.THREE)
			selectedLayer = 0;

		// Salir del editor
		if (FlxG.keys.justPressed.ESCAPE && !exited)
		{
			exited = true;
			FlxG.camera.fade(0x11111111, () ->
			{
				FlxG.mouse.visible = false;
				FlxG.switchState(new MenuState());
			});
		}

		// Menu Editor
		if (FlxG.keys.justPressed.ENTER)
		{
			var subState = new MapEditorSubState();
			subState.editorState = this;
			openSubState(subState);
		}

		textPos.text = 'X: $mouseX\nY: $mouseY';
	}

	// FlxState functions!
	override public function create()
	{
		super.create();
		FlxG.mouse.visible = true;
		FlxG.sound.music.stop();
		// persistentUpdate = true;
		// persistentDraw = true;

		var uiCamera:FlxCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		uiCamera.bgColor = FlxColor.TRANSPARENT;

		// UI stuff
		highlightBorders = new FlxSprite(0, 0);
		highlightBorders.makeGraphic(MAP_WIDTH * 12, MAP_HEIGHT * 12, FlxColor.TRANSPARENT);
		add(highlightBorders);
		FlxSpriteUtil.drawRect(highlightBorders, 0, 0, MAP_WIDTH * 12, MAP_HEIGHT * 12, FlxColor.TRANSPARENT, {color: FlxColor.RED});

		var backgroundBorder = new FlxSprite(0, FlxG.height - 16);
		backgroundBorder.makeGraphic(FlxG.width, 16, 0xFF0163C6);
		add(backgroundBorder);

		tileSelectedSprite = new FlxSprite(2, FlxG.height - 14);
		tileSelectedSprite.loadGraphic(Paths.getImage("tilemaps/grass"), true, 12, 12);
		add(tileSelectedSprite);

		textPos = new FlxBitmapText();
		textPos.setPosition(16, FlxG.height - 14);
		textPos.text = "X: 0\nY: 0";
		add(textPos);

		sprLayer2 = new FlxSprite(FlxG.width - 24, FlxG.height - 25);
		sprLayer2.loadGraphic(Paths.getImage("layer0"), true, 8, 9);
		add(sprLayer2);

		sprLayer1 = new FlxSprite(FlxG.width - 16, FlxG.height - 25);
		sprLayer1.loadGraphic(Paths.getImage("layer1"), true, 8, 9);
		sprLayer1.animation.frameIndex = 1;
		add(sprLayer1);

		sprLayer0 = new FlxSprite(FlxG.width - 8, FlxG.height - 25);
		sprLayer0.loadGraphic(Paths.getImage("layer2"), true, 8, 9);
		sprLayer0.animation.frameIndex = 1;
		add(sprLayer0);

		var mapEditorText = new FlxBitmapText(Fonts.TOY);
		mapEditorText.text = "MAP EDITOR";
		mapEditorText.x = FlxG.width - mapEditorText.width - 2;
		mapEditorText.y = FlxG.height - mapEditorText.height - 2;
		add(mapEditorText);

		// Map stuff
		createMap();

		highlightBox = new FlxSprite(0, 0);
		highlightBox.makeGraphic(TILE_WIDTH, TILE_HEIGHT, 0x99FF0000);
		add(highlightBox);

		// Configurar cámaras
		FlxG.cameras.add(uiCamera, false);
		backgroundBorder.cameras = [uiCamera];
		tileSelectedSprite.cameras = [uiCamera];
		textPos.cameras = [uiCamera];
		sprLayer2.cameras = [uiCamera];
		sprLayer1.cameras = [uiCamera];
		sprLayer0.cameras = [uiCamera];
		mapEditorText.cameras = [uiCamera];

		FlxG.camera.bgColor = FlxColor.BLACK;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		switch (editorState)
		{
			case Tilemap:
				onEditorUpdate();
			case Entity:
			case Playing:
		}
	}
}
