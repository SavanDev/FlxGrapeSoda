package editor;

#if EDITOR
import Gameplay;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxInputText;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRect;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;
import types.Entity;
import util.FlxSpriteEditor;

enum EditorMode
{
	Tilemap;
	Entity;
	PlayerSelection;
	Background;
	ExitWarning;
	Export;
	Load;
	Music;
	Sign;
}

enum ButtonShortcut
{
	BtnT;
	BtnE;
	BtnP;
	BtnH;
	BtnB;
	BtnS;
	BtnR;
	BtnG;
	BtnC;
	BtnX;
	BtnUp;
	BtnDown;
	BtnEsc;
}

enum Colors
{
	Red;
	Green;
	Blue;
}

typedef Shortcut =
{
	name:String,
	button:ButtonShortcut
}

class EditorState extends BaseState
{
	static inline var UI_ZOOM:Float = .1;
	static inline var MAX_WIDTH:Int = Game.WIDTH * Game.MAX_MULTIPLIER_WIDTH;
	static inline var SCROLL_SPEED:Int = 3;
	static inline var PLAYERS_SEPARATION:Int = 20;

	var editorState:EditorMode;
	var lastEditorState:EditorMode;
	var lastShortcut:Array<Shortcut>;
	var canChangeState:Bool = true;
	var canScroll:Bool = true;

	var tilemapUI:FlxGroup;
	var entityUI:FlxGroup;
	var playerUI:FlxGroup;
	var backgroundUI:FlxGroup;
	var exitUI:FlxGroup;
	var exportUI:FlxGroup;
	var shortcutUI:FlxGroup;
	var extraUI:FlxGroup;
	var musicUI:FlxGroup;
	var signUI:FlxGroup;

	var uiBorder:FlxSprite;
	var sprLayers:FlxSprite;

	var levelMap:FlxTypedGroup<FlxTilemap>;
	var selectedTile(default, set):Int = 1;
	var selectedLayer(default, set):Int = 2;

	var editorText:FlxText;
	var backParallax:BackParallax;
	var entities:FlxGroup;
	var actualPlayer:FlxSprite;

	var mouseX:Int;
	var mouseY:Int;
	var levelSize:FlxRect;

	// Player selector
	var players:FlxSpriteGroup;
	var playerSelected:Int = 0;
	var playerCursor:FlxSprite;

	// Tilemap
	var highlightBox:FlxSprite;
	var tileSelectedSprite:FlxSprite;
	var textPos:FlxBitmapText;
	var posBackground:FlxSprite;

	// Entities
	var currentEntity:FlxSpriteEditor;
	var currentEntityName:FlxText;

	var levelEntities:FlxTypedGroup<FlxSpriteEditor>;
	var entitiesPositions:Array<String>;

	var actualEntity:Int = 0;
	var levelHasPlayer:Bool = false;
	var levelHasFlag:Bool = false;

	// Background
	var redBack:FlxSprite;
	var greenBack:FlxSprite;
	var blueBack:FlxSprite;
	var selectedColor:Colors;
	var redValueUI:FlxBitmapText;
	var greenValueUI:FlxBitmapText;
	var blueValueUI:FlxBitmapText;
	var redValue:Int = 100;
	var greenValue:Int = 165;
	var blueValue:Int = 255;
	var backgroundTypeUI:FlxBitmapText;
	var backgroundType:Int = 0;
	var backgroundClouds:Bool = true;

	// Export
	var inputText:FlxInputText;
	var messageExport:FlxBitmapText;
	var saveTextUI:FlxBitmapText;

	// Music
	var inputMusic:FlxInputText;

	// Sign
	var inputSign:FlxInputText;
	var inputCounter:FlxText;
	var inputEntity:FlxSpriteEditor;

	static inline var BACKGROUND_TYPE_LIMIT:Int = 1; // Cantidad de fondos disponibles (contando el 0)

	var loadLevelAtStart:Bool = false;

	public function new(loadLevel:Bool = false)
	{
		super();
		loadLevelAtStart = loadLevel;
	}

	// Shortcuts!
	var shortcutsGeneral:Array<Shortcut> = [
		{
			name: "Tilemap",
			button: BtnT
		},
		{
			name: "Entity",
			button: BtnE
		},
		{
			name: "Players",
			button: BtnP
		},
		{
			name: "Background",
			button: BtnB
		},
		{
			name: "Hide UI",
			button: BtnH
		},
		{
			name: "Sounds",
			button: BtnS
		},
		{
			name: "Export level",
			button: BtnX
		},
		{
			name: "Exit",
			button: BtnEsc
		}
	];

	var shortcutsBackground:Array<Shortcut> = [
		{
			name: "Change red value",
			button: BtnR
		},
		{
			name: "Change green value",
			button: BtnG
		},
		{
			name: "Change blue value",
			button: BtnB
		},
		{
			name: "Increase value",
			button: BtnUp
		},
		{
			name: "Decrease value",
			button: BtnDown
		},
		{
			name: "Toggle clouds",
			button: BtnC
		},
		{
			name: "Back",
			button: BtnEsc
		}
	];

	var shortcutsSimple:Array<Shortcut> = [
		{
			name: "Back",
			button: BtnEsc
		}
	];

	var shortcutsMusic:Array<Shortcut> = [
		{
			name: "Stop music",
			button: BtnS
		},
		{
			name: "Back",
			button: BtnEsc
		}
	];

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

	function setLayerTilePreview()
	{
		var path:String = null;

		switch (selectedLayer)
		{
			case 0:
				path = Paths.getImage("tilemaps/backtiles");
				sprLayers.animation.frameIndex = 2;
			case 1:
				path = Paths.getImage("tilemaps/objects");
				sprLayers.animation.frameIndex = 1;
			case 2:
				path = Paths.getImage("tilemaps/grass");
				sprLayers.animation.frameIndex = 0;
		}

		tileSelectedSprite.loadGraphic(path, true, 12, 12);
		tileSelectedSprite.animation.frameIndex = selectedLayer == 2 ? 0 : selectedTile;
	}

	public function createMap()
	{
		var blankMap = [for (i in 0...MAX_WIDTH * Game.MAP_HEIGHT) 0];

		if (levelMap != null)
		{
			levelMap.forEach((tilemap) ->
			{
				levelMap.remove(tilemap);
				tilemap.destroy();
			});
			levelMap.clear();
		}
		else
		{
			levelMap = new FlxTypedGroup<FlxTilemap>();
			add(levelMap);
		}

		var layer2 = new FlxTilemap();
		layer2.loadMapFromArray(blankMap, MAX_WIDTH, Game.MAP_HEIGHT, Paths.getImage("tilemaps/backtiles"), Game.TILE_SIZE, Game.TILE_SIZE);
		levelMap.add(layer2);

		var layer1 = new FlxTilemap();
		layer1.loadMapFromArray(blankMap, MAX_WIDTH, Game.MAP_HEIGHT, Paths.getImage("tilemaps/objects"), Game.TILE_SIZE, Game.TILE_SIZE);
		levelMap.add(layer1);

		var layer0 = new FlxTilemap();
		layer0.loadMapFromArray(blankMap, MAX_WIDTH, Game.MAP_HEIGHT, Paths.getImage("tilemaps/grass"), Game.TILE_SIZE, Game.TILE_SIZE, FULL);
		levelMap.add(layer0);

		levelEntities = new FlxTypedGroup<FlxSpriteEditor>();
		add(levelEntities);
	}

	/*
		Tilemap functions
	 */
	function onEditorCreate()
	{
		tilemapUI = new FlxGroup();

		tileSelectedSprite = new FlxSprite(2, FlxG.height - 14);
		tileSelectedSprite.loadGraphic(Paths.getImage("tilemaps/grass"), true, 12, 12);
		tilemapUI.add(tileSelectedSprite);

		// Map stuff
		createMap();

		highlightBox = new FlxSprite(0, 0);
		highlightBox.makeGraphic(Game.TILE_SIZE, Game.TILE_SIZE, 0x99FF0000);
		tilemapUI.add(highlightBox);

		tileSelectedSprite.cameras = [uiCamera];

		add(tilemapUI);
	}

	function onEditorUpdate()
	{
		#if desktop
		if (FlxG.mouse.getPosition().inRect(levelSize))
		{
			highlightBox.x = mouseX * Game.TILE_SIZE;
			highlightBox.y = mouseY * Game.TILE_SIZE;
			highlightBox.visible = true;
		}
		else
			highlightBox.visible = false;

		if (FlxG.mouse.pressed && highlightBox.visible)
			levelMap.members[selectedLayer].setTile(mouseX, mouseY, selectedTile);
		if (FlxG.mouse.pressedRight && highlightBox.visible)
			levelMap.members[selectedLayer].setTile(mouseX, mouseY, 0);

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
		#end
	}

	/*
		Entities functions
	 */
	function onEntityCreate()
	{
		entityUI = new FlxGroup();
		entitiesPositions = new Array<String>();

		currentEntity = new FlxSpriteEditor(actualEntity);
		currentEntity.alpha = .75;
		currentEntity.solid = false;
		entityUI.add(currentEntity);

		currentEntityName = new FlxText(2, Game.HEIGHT - 18);
		currentEntityName.setFormat("assets/fonts/Toy.ttf", 16);
		currentEntityName.text = "PLAYER";
		entityUI.add(currentEntityName);

		currentEntityName.cameras = [uiCamera];

		add(entityUI);
	}

	function onEntityUpdate()
	{
		#if desktop
		if (FlxG.mouse.getPosition().inRect(levelSize))
		{
			currentEntity.x = Std.int(mouseX * Game.TILE_SIZE);
			currentEntity.y = Std.int(mouseY * Game.TILE_SIZE - (currentEntity.height - Game.TILE_SIZE));
		}

		if (FlxG.mouse.wheel < 0)
		{
			actualEntity++;
			changeEntityPreview();
		}

		if (FlxG.mouse.wheel > 0)
		{
			actualEntity--;
			changeEntityPreview();
		}

		if (FlxG.mouse.pressed && !(actualEntity == 0 && levelHasPlayer) && !(actualEntity == 3 && levelHasFlag))
			addEntityToMap();

		if (FlxG.mouse.pressedRight)
			removeEntityToMap();
		#end
	}

	function addEntityToMap()
	{
		var entityPos:String = '${currentEntity.x}-${currentEntity.y}';
		var newEntityCopy = new FlxSpriteEditor(currentEntity.getEntityType(), currentEntity.x, currentEntity.y);

		if (!entitiesPositions.contains(entityPos))
		{
			levelEntities.add(newEntityCopy);
			entitiesPositions.push(entityPos);

			if (actualEntity == 0)
				levelHasPlayer = true;

			if (actualEntity == 3)
				levelHasFlag = true;

			if (actualEntity == 5)
			{
				inputEntity = newEntityCopy;
				changeState(Sign);
			}
		}
		else
		{
			var entityIndex:Int = entitiesPositions.indexOf(entityPos);
			var entity:FlxSpriteEditor = levelEntities.members[entityIndex];

			if (entity.getEntityType() == 5)
			{
				if (entity.message != null)
				{
					inputSign.text = entity.message;
					inputSign.caretIndex = inputSign.text.length;
				}
				inputEntity = entity;
				changeState(Sign);
			}
		}
	}

	function removeEntityToMap()
	{
		var entityPos:String = '${currentEntity.x}-${currentEntity.y}';
		if (entitiesPositions.contains(entityPos))
		{
			var entityIndex:Int = entitiesPositions.indexOf(entityPos);
			var entity:FlxSpriteEditor = levelEntities.members[entityIndex];

			if (entity.getEntityType() == 0)
				levelHasPlayer = false;

			if (entity.getEntityType() == 3)
				levelHasFlag = false;

			levelEntities.remove(entity, true);
			entity.destroy();
			entitiesPositions.remove(entityPos);
		}
	}

	function changeEntityPreview()
	{
		if (actualEntity >= MAX_ENTITIES)
			actualEntity = 0;

		if (actualEntity < 0)
			actualEntity = MAX_ENTITIES - 1;

		currentEntityName.text = currentEntity.getEntityName(actualEntity);
		currentEntity.setEntityType(actualEntity);
	}

	// Player selector
	function onPlayersCreate()
	{
		playerUI = new FlxGroup();

		var names = ["dylan", "luka", "watanoge", "asdonaur"];
		var baseX:Int = 0;
		players = new FlxSpriteGroup();

		var playerBackground = new FlxSprite();
		playerBackground.makeGraphic(Std.int(Game.WIDTH / 2), Std.int(Game.HEIGHT / 2), 0xAA000000);
		playerBackground.screenCenter();
		playerBackground.y -= 10;
		playerUI.add(playerBackground);

		playerCursor = new FlxSprite();
		playerCursor.loadGraphic(Paths.getImage("player-select"), false, 8, 8);
		playerUI.add(playerCursor);

		for (v in names)
		{
			var player:FlxSprite = new FlxSprite(baseX);
			player.loadGraphic(Paths.getImage('skins/$v'), true, 12, 24);
			player.animation.add("default", [1, 2], 3);
			player.animation.play("default");
			players.add(player);

			var playerNumber:FlxBitmapText = new FlxBitmapText();
			playerNumber.setPosition(baseX + 4, player.y + player.height + 5);
			playerNumber.text = baseX == 0 ? "1" : '${(baseX / 20) + 1}';
			players.add(playerNumber);

			baseX += PLAYERS_SEPARATION;
		}

		var titleSelector:FlxText = new FlxText(0, 35, "Select a player!");
		titleSelector.screenCenter(X);
		players.screenCenter();

		playerCursor.setPosition(players.x + 2, 48);
		FlxTween.num(playerCursor.y, playerCursor.y + 2, .5, {type: PINGPONG}, (v) -> playerCursor.y = v);

		playerUI.add(titleSelector);
		playerUI.add(players);
		playerUI.visible = false;
		playerUI.cameras = [uiCamera];
		add(playerUI);
	}

	function onPlayersUpdate()
	{
		#if desktop
		if (FlxG.keys.justPressed.ONE)
			changePlayerCursor(0);

		if (FlxG.keys.justPressed.TWO)
			changePlayerCursor(1);

		if (FlxG.keys.justPressed.THREE)
			changePlayerCursor(2);

		if (FlxG.keys.justPressed.FOUR)
			changePlayerCursor(3);
		#end
	}

	function changePlayerCursor(index:Int)
	{
		if (index != playerSelected)
		{
			playerSelected = index;
			actualPlayer.animation.frameIndex = index;
			playerCursor.x = players.x + (PLAYERS_SEPARATION * index) + 2;
		}
		else
			changeState(Entity);
	}

	/*
		Level data generation (Save system)
	 */
	function getEntitiesData()
	{
		var entities:Array<Entity> = new Array<Entity>();
		levelEntities.forEach((entity) ->
		{
			var newEntity:Entity = {
				type: entity.getEntityType(),
				x: entity.x,
				y: entity.y
			};

			if (entity.message != null)
				newEntity.msg = entity.message;

			entities.push(newEntity);
		});

		return Json.stringify(entities);
	}

	function getMapData(layer:Int)
	{
		/*
			0 => layer 2
			1 => layer 1
			2 => layer 0
		 */
		if (layer >= 0 && layer <= 2)
		{
			if (layer != 0)
				return Json.stringify(levelMap.members[2 - layer].getData());
			else
				return Json.stringify(levelMap.members[2 - layer].getData(true));
		}
		else
			return null;
	}

	function generateJSONLevel()
	{
		var result:LevelData = {
			layers: [getMapData(0), getMapData(1), getMapData(2)],
			entities: getEntitiesData(),
			player: playerSelected,
			background: {
				type: backgroundType,
				clouds: backgroundClouds,
				redValue: redValue,
				greenValue: greenValue,
				blueValue: blueValue
			},
			music: inputMusic.text
		};
		return Json.stringify(result, "\t");
	}

	/*
		Level data generation (Load system)
	 */
	function setEntitiesData(entitiesJSON:String)
	{
		var entities:Array<Entity> = Json.parse(entitiesJSON);

		// Clear entities in the scene
		levelEntities.forEach((entity) ->
		{
			levelEntities.remove(entity);
			entity.destroy();
		});
		levelEntities.clear();

		while (entitiesPositions.length > 0)
			entitiesPositions.pop();

		// Load entities
		for (entity in entities)
		{
			var newEntity = new FlxSpriteEditor(entity.type, entity.x, entity.y);

			if (entity.msg != null)
				newEntity.message = entity.msg;

			levelEntities.add(newEntity);
			entitiesPositions.push('${entity.x}-${entity.y}');

			if (entity.type == 0 && !levelHasPlayer)
				levelHasPlayer = true;

			if (entity.type == 3 && !levelHasFlag)
				levelHasFlag = true;
		}
	}

	function setMapData(layers:Array<String>)
	{
		// hard code layers
		levelMap.members[0].loadMapFromArray(Json.parse(layers[2]), MAX_WIDTH, Game.MAP_HEIGHT, Paths.getImage("tilemaps/backtiles"), Game.TILE_SIZE,
			Game.TILE_SIZE);
		levelMap.members[1].loadMapFromArray(Json.parse(layers[1]), MAX_WIDTH, Game.MAP_HEIGHT, Paths.getImage("tilemaps/objects"), Game.TILE_SIZE,
			Game.TILE_SIZE);
		levelMap.members[2].loadMapFromArray(Json.parse(layers[0]), MAX_WIDTH, Game.MAP_HEIGHT, Paths.getImage("tilemaps/grass"), Game.TILE_SIZE,
			Game.TILE_SIZE, FULL);
	}

	function readJSONLevel()
	{
		var level:LevelData = Json.parse(File.getContent('maps/${inputText.text}.json'));
		trace(level);

		setMapData(level.layers);
		setEntitiesData(level.entities);
		changePlayerCursor(level.player);
		changeBackType(level.background.type);
		if (backParallax.cloudsVisible() != level.background.clouds)
			backParallax.toggleClouds();
		backgroundClouds = level.background.clouds;

		changeBackgroundColorValues(level.background.redValue, level.background.greenValue, level.background.blueValue);
	}

	/*
		Shortcuts functions
	 */
	function generateShortcutViewer(shortcuts:Array<Shortcut>)
	{
		if (shortcutUI == null)
		{
			shortcutUI = new FlxGroup();
			add(shortcutUI);
			shortcutUI.cameras = [uiCamera];
		}

		if (shortcutUI.members.length > 0 && lastShortcut != shortcuts)
		{
			shortcutUI.forEach((object) -> object.destroy());
			shortcutUI.clear();
		}

		if (shortcutUI.members.length == 0)
		{
			var baseY:Int = 12;
			for (sc in shortcuts)
			{
				var shortcutButton:FlxSprite = new FlxSprite(Game.WIDTH - 14, baseY);
				shortcutButton.loadGraphic(Paths.getImage("buttons"), true, 9, 9);
				shortcutButton.animation.frameIndex = sc.button.getIndex();

				var shortcutText:FlxBitmapText = new FlxBitmapText();
				shortcutText.text = sc.name;
				shortcutText.setPosition(shortcutButton.x - shortcutText.width - 2, baseY + 2);
				shortcutText.setBorderStyle(SHADOW, FlxColor.BLACK);

				shortcutUI.add(shortcutButton);
				shortcutUI.add(shortcutText);

				baseY += 10;
			}

			lastShortcut = shortcuts;
		}
	}

	/*
		Background selector
	 */
	function onBackgroundCreate()
	{
		backgroundUI = new FlxGroup();

		var topBack:FlxSprite = new FlxSprite();
		topBack.makeGraphic(Game.WIDTH, 10, FlxColor.BLACK);
		backgroundUI.add(topBack);

		redBack = new FlxSprite(0, uiBorder.y);
		redBack.makeGraphic(30, Std.int(uiBorder.height), FlxColor.RED);
		backgroundUI.add(redBack);

		greenBack = new FlxSprite(30, uiBorder.y);
		greenBack.makeGraphic(30, Std.int(uiBorder.height), FlxColor.GREEN);
		backgroundUI.add(greenBack);

		blueBack = new FlxSprite(60, uiBorder.y);
		blueBack.makeGraphic(30, Std.int(uiBorder.height), FlxColor.BLUE);
		backgroundUI.add(blueBack);

		var marginX:Int = 7;
		var marginY:Int = 5;

		redValueUI = new FlxBitmapText();
		redValueUI.setPosition(redBack.x + marginX, uiBorder.y + marginY);
		redValueUI.text = '$redValue';
		backgroundUI.add(redValueUI);

		greenValueUI = new FlxBitmapText();
		greenValueUI.setPosition(greenBack.x + marginX, uiBorder.y + marginY);
		greenValueUI.text = '$greenValue';
		backgroundUI.add(greenValueUI);

		blueValueUI = new FlxBitmapText();
		blueValueUI.setPosition(blueBack.x + marginX, uiBorder.y + marginY);
		blueValueUI.text = '$blueValue';
		backgroundUI.add(blueValueUI);

		var leftArrow = new FlxBitmapText();
		leftArrow.setPosition(3, 2);
		leftArrow.text = "<";
		backgroundUI.add(leftArrow);

		backgroundTypeUI = new FlxBitmapText();
		backgroundTypeUI.setPosition(0, 2);
		backgroundTypeUI.fieldWidth = FlxG.width;
		backgroundTypeUI.autoSize = false;
		backgroundTypeUI.alignment = CENTER;
		backgroundTypeUI.text = "Overworld";
		backgroundUI.add(backgroundTypeUI);

		var rightArrow = new FlxBitmapText();
		rightArrow.setPosition(Game.WIDTH - 7, 2);
		rightArrow.text = ">";
		backgroundUI.add(rightArrow);

		changeSelectedColor(Red);
		backgroundUI.cameras = [uiCamera];
		add(backgroundUI);
	}

	function changeBackType(value:Int)
	{
		backgroundType = value;

		if (backgroundType < 0)
			backgroundType = BACKGROUND_TYPE_LIMIT;

		if (backgroundType > BACKGROUND_TYPE_LIMIT)
			backgroundType = 0;

		switch (backgroundType)
		{
			case 0:
				backgroundTypeUI.text = "Overworld";
			case 1:
				backgroundTypeUI.text = "City";
		}

		backParallax.setBackgroundType(backgroundType);
	}

	function changeBackValue(value:Int)
	{
		switch (selectedColor)
		{
			case Red:
				redValue += value;
			case Green:
				greenValue += value;
			case Blue:
				blueValue += value;
		}

		updateBackColors();
	}

	function changeBackgroundColorValues(red:Int, green:Int, blue:Int)
	{
		redValue = red;
		greenValue = green;
		blueValue = blue;

		updateBackColors();
	}

	function updateBackColors()
	{
		// Comprobemos que los valores sean válidos
		if (redValue < 0)
			redValue = 0;

		if (redValue > 255)
			redValue = 255;

		if (greenValue < 0)
			greenValue = 0;

		if (greenValue > 255)
			greenValue = 255;

		if (blueValue < 0)
			blueValue = 0;

		if (blueValue > 255)
			blueValue = 255;

		// Ahora mostremos los nuevos valores en pantalla
		redValueUI.text = '$redValue';
		greenValueUI.text = '$greenValue';
		blueValueUI.text = '$blueValue';

		FlxG.camera.bgColor.setRGB(redValue, greenValue, blueValue);
	}

	function changeSelectedColor(color:Colors)
	{
		switch (color)
		{
			case Red:
				redBack.alpha = 1;
				greenBack.alpha = .25;
				blueBack.alpha = .25;
			case Green:
				redBack.alpha = .25;
				greenBack.alpha = 1;
				blueBack.alpha = .25;
			case Blue:
				redBack.alpha = .25;
				greenBack.alpha = .25;
				blueBack.alpha = 1;
		}
		selectedColor = color;
	}

	function onBackgroundUpdate()
	{
		if (FlxG.keys.justPressed.R)
			changeSelectedColor(Red);

		if (FlxG.keys.justPressed.G)
			changeSelectedColor(Green);

		if (FlxG.keys.justPressed.B)
			changeSelectedColor(Blue);

		if (FlxG.keys.pressed.UP)
			changeBackValue(1);

		if (FlxG.keys.pressed.DOWN)
			changeBackValue(-1);

		if (FlxG.keys.justPressed.RIGHT)
			changeBackType(backgroundType + 1);

		if (FlxG.keys.justPressed.LEFT)
			changeBackType(backgroundType - 1);

		if (FlxG.keys.justPressed.C)
		{
			backParallax.toggleClouds();
			backgroundClouds = !backgroundClouds;
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			changeState(lastEditorState);
			new FlxTimer().start(.1, (tmr) -> canChangeState = true);
		}
	}

	/*
		Exit Warning
	 */
	function onExitCreate()
	{
		exitUI = new FlxGroup();

		var exitBackground = new FlxSprite();
		exitBackground.makeGraphic(Game.WIDTH, Game.HEIGHT, 0xAA000000);
		exitBackground.screenCenter();
		exitUI.add(exitBackground);

		var exitText = new FlxBitmapText();
		exitText.text = "Are you sure you want to leave the editor?\nAll unavailable changes will be erased!\n\nPress ESC again to exit.\nPress ENTER to cancel and back.";
		exitText.multiLine = true;
		exitText.alignment = CENTER;
		exitText.screenCenter();
		exitUI.add(exitText);

		exitUI.cameras = [uiCamera];
		add(exitUI);
	}

	function onExitUpdate()
	{
		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.mouse.visible = false;
			FlxG.switchState(new MenuState());
		}
		if (FlxG.keys.justPressed.ENTER)
		{
			changeState(lastEditorState);
			new FlxTimer().start(.1, (tmr) -> canChangeState = true);
		}
	}

	/*
		Export level
	 */
	function onExportCreate()
	{
		exportUI = new FlxGroup();

		var width:Int = Std.int(Game.WIDTH / 2);
		var height:Int = Std.int(Game.HEIGHT / 2);

		var exportBackground = new FlxSprite(5, 5);
		exportBackground.makeGraphic(width, height, 0xAA000000);
		exportUI.add(exportBackground);

		var levelNameUI = new FlxBitmapText();
		levelNameUI.setPosition(10, 10);
		levelNameUI.text = "Level name:";
		exportUI.add(levelNameUI);

		inputText = new FlxInputText(10, 20, width - 10, "level");
		exportUI.add(inputText);

		messageExport = new FlxBitmapText();
		messageExport.setPosition(10, inputText.y + inputText.height + 5);
		messageExport.text = 'The level will be saved in:\n"maps/*"';
		messageExport.multiLine = true;
		exportUI.add(messageExport);

		saveTextUI = new FlxBitmapText();
		saveTextUI.setPosition(width - 35, height - 10);
		saveTextUI.text = "Save";
		exportUI.add(saveTextUI);

		var saveButtonUI = new FlxSprite(width - 15, height - 15);
		saveButtonUI.loadGraphic(Paths.getImage("enter-button"));
		exportUI.add(saveButtonUI);

		exportUI.cameras = [uiCamera];
		add(exportUI);
	}

	function onExportUpdate()
	{
		if (FlxG.keys.justPressed.ENTER)
			exportLevel();

		if (FlxG.keys.justPressed.ESCAPE)
		{
			inputText.hasFocus = false;
			changeState(lastEditorState);
			new FlxTimer().start(.1, (tmr) -> canChangeState = true);
		}
	}

	function exportLevel()
	{
		if (!FileSystem.exists("maps"))
			FileSystem.createDirectory("maps");

		File.saveContent('maps/${inputText.text}.json', generateJSONLevel());
		messageExport.text = "Level saved!";
		trace("Map exported successful!");
	}

	/*
		Load level
	 */
	function onLoadCreate()
	{
		messageExport.text = 'The level should be at:\n"maps/*"';
		saveTextUI.text = "Load";
	}

	function onLoadUpdate()
	{
		if (FlxG.keys.justPressed.ENTER)
		{
			readJSONLevel();
			changeState(Tilemap);
			inputText.hasFocus = false;
			new FlxTimer().start((tmr) -> canChangeState = true);
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			changeState(Tilemap);
			inputText.hasFocus = false;
			new FlxTimer().start((tmr) -> canChangeState = true);
		}
	}

	/*
		Music options
	 */
	function onMusicCreate()
	{
		musicUI = new FlxGroup();

		var width:Int = Std.int(Game.WIDTH / 2);
		var height:Int = Std.int(Game.HEIGHT / 2 + 20);

		var musicBackground = new FlxSprite(5, 5);
		musicBackground.makeGraphic(width, height, 0xAA000000);
		musicUI.add(musicBackground);

		var musicFileNameUI = new FlxBitmapText();
		musicFileNameUI.setPosition(10, 10);
		musicFileNameUI.text = "File name:";
		musicUI.add(musicFileNameUI);

		inputMusic = new FlxInputText(10, 20, width - 10, "50s-bit");
		musicUI.add(inputMusic);

		var messageMusic = new FlxBitmapText();
		messageMusic.setPosition(10, inputText.y + inputText.height + 5);
		messageMusic.text = 'The file should be at:\n"maps/music/*.ogg"\nor\n"assets/music/*.ogg"';
		messageMusic.multiLine = true;
		musicUI.add(messageMusic);

		var musicTestUI = new FlxBitmapText();
		musicTestUI.setPosition(width - 35, height - 10);
		musicTestUI.text = "Play";
		musicUI.add(musicTestUI);

		var saveButtonUI = new FlxSprite(width - 15, height - 15);
		saveButtonUI.loadGraphic(Paths.getImage("enter-button"));
		musicUI.add(saveButtonUI);

		musicUI.cameras = [uiCamera];
		add(musicUI);
	}

	function onMusicUpdate()
	{
		if (FlxG.keys.justPressed.ENTER)
			FlxG.sound.playMusic(Paths.getMusic(inputMusic.text));

		if (FlxG.keys.justPressed.S && FlxG.sound.music.playing)
			FlxG.sound.music.stop();

		if (FlxG.keys.justPressed.ESCAPE)
		{
			changeState(lastEditorState);
			new FlxTimer().start(.1, (tmr) -> canChangeState = true);
		}
	}

	/*
		Sign options
	 */
	function onSignCreate()
	{
		signUI = new FlxGroup();

		var signBackground = new FlxSprite(Paths.getImage("hud/sign"));
		signBackground.setPosition(5, FlxG.height - 16 - signBackground.height);
		signUI.add(signBackground);

		inputSign = new FlxInputText(signBackground.x + 5, signBackground.y + 5, Std.int(signBackground.width - 10));
		inputSign.maxLength = 30;
		signUI.add(inputSign);

		inputCounter = new FlxText(5, signBackground.y - 16);
		inputCounter.text = '${inputSign.text.length}/${inputSign.maxLength}';
		signUI.add(inputCounter);

		signUI.cameras = [uiCamera];
		add(signUI);
	}

	function onSignUpdate()
	{
		inputCounter.text = '${inputSign.text.length}/${inputSign.maxLength}';

		if (FlxG.keys.justPressed.ESCAPE)
		{
			if (inputEntity != null)
				inputEntity.message = inputSign.text;

			inputEntity = null;
			inputSign.text = "";
			inputSign.hasFocus = false;

			changeState(Entity);
			new FlxTimer().start(.1, (tmr) -> canChangeState = true);
		}
	}

	/*
		FlxState functions
	 */
	override public function create()
	{
		super.create();

		#if desktop
		FlxG.mouse.visible = true;
		#end
		FlxG.sound.music.stop();

		backParallax = new BackParallax(backgroundType, backgroundClouds);
		add(backParallax);

		// UI stuff
		uiBorder = new FlxSprite(0, FlxG.height - 16);
		uiBorder.makeGraphic(FlxG.width, 16, 0xFF0163C6);
		add(uiBorder);

		var infoPositionX:Float = Game.WIDTH / 2 + 30;

		// Extra UI
		extraUI = new FlxGroup();

		posBackground = new FlxSprite(infoPositionX, Game.HEIGHT - 16);
		posBackground.makeGraphic(30, 16, 0xFF004D99);
		extraUI.add(posBackground);

		textPos = new FlxBitmapText();
		textPos.setPosition(infoPositionX + 2, Game.HEIGHT - 14);
		textPos.text = "X: 0\nY: 0";
		extraUI.add(textPos);

		actualPlayer = new FlxSprite(infoPositionX - 15, Game.HEIGHT - 14);
		actualPlayer.loadGraphic(Paths.getImage("players"), true, 12, 12);
		extraUI.add(actualPlayer);

		add(extraUI);

		// States UI
		onEditorCreate();
		onEntityCreate();
		onBackgroundCreate();
		onPlayersCreate();
		onExportCreate();
		onExitCreate();
		onMusicCreate();
		onSignCreate();

		sprLayers = new FlxSprite(Game.WIDTH - 40, uiBorder.y - 9);
		sprLayers.loadGraphic(Paths.getImage("layers"), true, 32, 9);
		add(sprLayers);

		editorText = new FlxText(Game.WIDTH - 102, Game.HEIGHT - 18, 100, "LEVEL EDITOR");
		editorText.setFormat("assets/fonts/Toy.ttf", 16, RIGHT);
		add(editorText);

		// Configurar cámaras
		uiBorder.cameras = [uiCamera];
		sprLayers.cameras = [uiCamera];
		editorText.cameras = [uiCamera];
		posBackground.cameras = [uiCamera];
		textPos.cameras = [uiCamera];
		actualPlayer.cameras = [uiCamera];

		changeBackValue(0);
		changeState(!loadLevelAtStart ? Tilemap : Load);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		#if desktop
		// Selector y función para colocar y sacar
		mouseX = Std.int(FlxG.mouse.x / Game.TILE_SIZE);
		mouseY = Std.int(FlxG.mouse.y / Game.TILE_SIZE);
		levelSize = new FlxRect(0, 0, MAX_WIDTH - 1, Game.HEIGHT - 1);

		switch (editorState)
		{
			case Tilemap:
				onEditorUpdate();
			case Entity:
				onEntityUpdate();
			case PlayerSelection:
				onPlayersUpdate();
			case Background:
				onBackgroundUpdate();
			case ExitWarning:
				onExitUpdate();
			case Export:
				onExportUpdate();
			case Load:
				onLoadUpdate();
			case Music:
				onMusicUpdate();
			case Sign:
				onSignUpdate();
		}

		if (FlxG.mouse.getPosition().y >= sprLayers.y)
		{
			if (uiBorder.alpha > .5)
				uiBorder.alpha = posBackground.alpha = sprLayers.alpha -= .1;
		}
		else
		{
			if (uiBorder.alpha < 1)
				uiBorder.alpha = posBackground.alpha = sprLayers.alpha += .1;
		}

		if (editorState == Tilemap || editorState == Entity)
		{
			if (FlxG.keys.justPressed.H)
				uiCamera.visible = !uiCamera.visible;
		}

		if (canChangeState)
		{
			if (FlxG.keys.justPressed.E)
				changeState(Entity);

			if (FlxG.keys.justPressed.T)
				changeState(Tilemap);

			if (FlxG.keys.justPressed.P)
				changeState(PlayerSelection);

			if (FlxG.keys.justPressed.B)
				changeState(Background);

			if (FlxG.keys.justPressed.X)
				changeState(Export);

			if (FlxG.keys.justPressed.S)
				changeState(Music);

			if (FlxG.keys.justPressed.ESCAPE)
				changeState(ExitWarning);

			if (FlxG.keys.justPressed.C)
				changeState(Sign);
		}

		// Ajustes para el "offset"
		if (FlxG.keys.pressed.RIGHT && FlxG.camera.scroll.x < MAX_WIDTH - Game.WIDTH && canScroll)
			FlxG.camera.scroll.x += SCROLL_SPEED;

		if (FlxG.keys.pressed.LEFT && FlxG.camera.scroll.x > 0 && canScroll)
			FlxG.camera.scroll.x -= SCROLL_SPEED;

		textPos.text = 'X: $mouseX\nY: $mouseY';

		#if debug
		// TESTING ONLY
		FlxG.watch.addQuick("Mouse X", mouseX);
		FlxG.watch.addQuick("Mouse Y", mouseY);
		FlxG.watch.addQuick("Mouse Sel. X", mouseX * Game.TILE_SIZE);
		FlxG.watch.addQuick("Mouse Sel. Y", mouseY * Game.TILE_SIZE);
		#end
		#end
	}

	function changeState(state:EditorMode)
	{
		switch (state)
		{
			case Tilemap:
				tilemapUI.visible = true;
				entityUI.visible = false;
				playerUI.visible = false;
				extraUI.visible = true;
				backgroundUI.visible = false;
				canScroll = true;
				generateShortcutViewer(shortcutsGeneral);
				setLayerTilePreview();
				exitUI.visible = false;
				exportUI.visible = false;
				shortcutUI.visible = true;
				editorText.text = "LEVEL EDITOR";
				musicUI.visible = false;
				signUI.visible = false;
			case Entity:
				tilemapUI.visible = false;
				entityUI.visible = true;
				playerUI.visible = false;
				extraUI.visible = true;
				backgroundUI.visible = false;
				sprLayers.animation.frameIndex = 3;
				canScroll = true;
				generateShortcutViewer(shortcutsGeneral);
				exitUI.visible = false;
				exportUI.visible = false;
				editorText.text = "ENTITY EDITOR";
				musicUI.visible = false;
				signUI.visible = false;
			case PlayerSelection:
				tilemapUI.visible = false;
				entityUI.visible = false;
				playerUI.visible = true;
				extraUI.visible = false;
				backgroundUI.visible = false;
				canScroll = false;
				generateShortcutViewer(shortcutsGeneral);
				exitUI.visible = false;
				exportUI.visible = false;
				editorText.text = "PLAYER EDITOR";
				musicUI.visible = false;
				signUI.visible = false;
			case Background:
				tilemapUI.visible = false;
				entityUI.visible = false;
				playerUI.visible = false;
				extraUI.visible = false;
				backgroundUI.visible = true;
				canScroll = false;
				generateShortcutViewer(shortcutsBackground);
				exitUI.visible = false;
				exportUI.visible = false;
				canChangeState = false;
				editorText.text = "BACKGROUND EDITOR";
				musicUI.visible = false;
				signUI.visible = false;
			case ExitWarning:
				exitUI.visible = true;
				tilemapUI.visible = false;
				entityUI.visible = false;
				playerUI.visible = false;
				extraUI.visible = false;
				backgroundUI.visible = false;
				canScroll = false;
				canChangeState = false;
				shortcutUI.visible = false;
				exportUI.visible = false;
				editorText.text = "";
				musicUI.visible = false;
				signUI.visible = false;
			case Export:
				exitUI.visible = false;
				tilemapUI.visible = false;
				entityUI.visible = false;
				playerUI.visible = false;
				extraUI.visible = false;
				backgroundUI.visible = false;
				canScroll = false;
				canChangeState = false;
				exportUI.visible = true;
				messageExport.text = 'The level will be saved in:\n"maps/*"';
				saveTextUI.text = "Save";
				generateShortcutViewer(shortcutsSimple);
				editorText.text = "EXPORT LEVEL";
				musicUI.visible = false;
				signUI.visible = false;
				if (!uiCamera.visible)
					uiCamera.visible = true;
			case Load:
				exitUI.visible = false;
				tilemapUI.visible = false;
				entityUI.visible = false;
				playerUI.visible = false;
				extraUI.visible = false;
				backgroundUI.visible = false;
				canScroll = false;
				canChangeState = false;
				exportUI.visible = true;
				messageExport.text = 'The level should be at:\n"maps/*"';
				saveTextUI.text = "Load";
				generateShortcutViewer(shortcutsSimple);
				editorText.text = "LOAD LEVEL";
				musicUI.visible = false;
				signUI.visible = false;
			case Music:
				exitUI.visible = false;
				tilemapUI.visible = false;
				entityUI.visible = false;
				playerUI.visible = false;
				extraUI.visible = false;
				backgroundUI.visible = false;
				canScroll = false;
				canChangeState = false;
				exportUI.visible = false;
				musicUI.visible = true;
				signUI.visible = false;
				generateShortcutViewer(shortcutsMusic);
				editorText.text = "MUSIC LEVEL";
			case Sign:
				exitUI.visible = false;
				tilemapUI.visible = false;
				entityUI.visible = false;
				playerUI.visible = false;
				extraUI.visible = false;
				backgroundUI.visible = false;
				canScroll = false;
				canChangeState = false;
				exportUI.visible = false;
				musicUI.visible = false;
				signUI.visible = true;
				generateShortcutViewer(shortcutsSimple);
				editorText.text = "SIGN EDITOR";
		}

		if (editorState != null)
			lastEditorState = editorState;

		editorState = state;
	}
}
#end
