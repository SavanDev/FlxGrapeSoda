package editor;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import openfl.utils.Dictionary;
import types.Entity;

enum EditorMode
{
	Tilemap;
	Entity;
}

class EditorState extends BaseState
{
	static inline var MAX_WIDTH:Int = Game.WIDTH * 7;
	static inline var SCROLL_SPEED:Int = 3;

	var editorState:EditorMode = Tilemap;
	var canChangeState:Bool = true;

	var tilemapUI:FlxGroup;
	var entityUI:FlxGroup;
	var menuUI:FlxGroup;

	var uiBorder:FlxSprite;
	var sprLayers:FlxSprite;
	var blackBackground:FlxSprite;

	var levelMap:FlxTypedGroup<FlxTilemap>;
	var selectedTile(default, set):Int = 1;
	var selectedLayer(default, set):Int = 2;

	var editorText:FlxText;
	var backParallax:BackParallax;
	var entities:FlxGroup;

	var mouseX:Int;
	var mouseY:Int;
	var levelSize:FlxRect;

	// Tilemap
	var highlightBox:FlxSprite;
	var tileSelectedSprite:FlxSprite;
	var textPos:FlxBitmapText;

	// Entities
	var currentEntity:FlxSprite;
	var currentEntityName:FlxText;

	var levelEntities:FlxSpriteGroup;
	var entitiesPositions:Array<Entity>;
	var entitiesDictionary:Dictionary<Int, Int>; // For delete use

	var actualEntity:Int = 0;
	var levelHasPlayer:Bool = false;

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
				path = Paths.getImage("tilemaps/backgrass");
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
		var testMap = [for (i in 0...MAX_WIDTH * Game.MAP_HEIGHT) 0];

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
		layer2.loadMapFromArray(testMap, MAX_WIDTH, Game.MAP_HEIGHT, Paths.getImage("tilemaps/backgrass"), Game.TILE_SIZE, Game.TILE_SIZE);
		levelMap.add(layer2);

		var layer1 = new FlxTilemap();
		layer1.loadMapFromArray(testMap, MAX_WIDTH, Game.MAP_HEIGHT, Paths.getImage("tilemaps/objects"), Game.TILE_SIZE, Game.TILE_SIZE);
		levelMap.add(layer1);

		var layer0 = new FlxTilemap();
		layer0.loadMapFromArray(testMap, MAX_WIDTH, Game.MAP_HEIGHT, Paths.getImage("tilemaps/grass"), Game.TILE_SIZE, Game.TILE_SIZE, FULL);
		levelMap.add(layer0);

		levelEntities = new FlxSpriteGroup();
		entitiesPositions = new Array<Entity>();
		add(levelEntities);
	}

	/*
		Tilemap functions
	 */
	function onEditorCreate()
	{
		tileSelectedSprite = new FlxSprite(2, FlxG.height - 14);
		tileSelectedSprite.loadGraphic(Paths.getImage("tilemaps/grass"), true, 12, 12);
		tilemapUI.add(tileSelectedSprite);

		textPos = new FlxBitmapText();
		textPos.setPosition(16, Game.HEIGHT - 14);
		textPos.text = "X: 0\nY: 0";
		tilemapUI.add(textPos);

		// Map stuff
		createMap();

		highlightBox = new FlxSprite(0, 0);
		highlightBox.makeGraphic(Game.TILE_SIZE, Game.TILE_SIZE, 0x99FF0000);
		tilemapUI.add(highlightBox);

		tileSelectedSprite.cameras = [uiCamera];
		textPos.cameras = [uiCamera];

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

		if (FlxG.keys.justPressed.NUMPADEIGHT)
			backParallax.y++;

		if (FlxG.keys.justPressed.NUMPADTWO)
			backParallax.y--;

		// Ajustes para el "offset"
		if (FlxG.keys.pressed.RIGHT && FlxG.camera.scroll.x < MAX_WIDTH - Game.WIDTH)
			FlxG.camera.scroll.x += SCROLL_SPEED;

		if (FlxG.keys.pressed.LEFT && FlxG.camera.scroll.x > 0)
			FlxG.camera.scroll.x -= SCROLL_SPEED;

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

		textPos.text = 'X: $mouseX\nY: $mouseY';
		#end
	}

	/*
		Entities functions
	 */
	function onEntityCreate()
	{
		currentEntity = new FlxSprite();
		currentEntity.alpha = .75;
		entityUI.add(currentEntity);

		currentEntityName = new FlxText(2, Game.HEIGHT - 18);
		currentEntityName.setFormat("assets/fonts/Toy.ttf", 16);
		entityUI.add(currentEntityName);

		loadEntity(currentEntity);

		currentEntityName.cameras = [uiCamera];

		add(entityUI);
	}

	function onEntityUpdate()
	{
		#if desktop
		if (FlxG.mouse.getPosition().inRect(levelSize))
		{
			currentEntity.x = mouseX * Game.TILE_SIZE;
			currentEntity.y = mouseY * Game.TILE_SIZE - (currentEntity.height - Game.TILE_SIZE);
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

		if (FlxG.mouse.justPressed && ((actualEntity == 0 && !levelHasPlayer) || actualEntity != 0))
		{
			var entityPos:FlxPoint = new FlxPoint(currentEntity.x, currentEntity.y);
			var newEntitySprite:FlxSprite = new FlxSprite(entityPos.x, entityPos.y);
			var newEntity:Entity = {
				type: actualEntity,
				x: entityPos.x,
				y: entityPos.y
			};

			loadEntity(newEntitySprite);
			levelEntities.add(newEntitySprite);
			entitiesPositions.insert(entitiesPositions.length - 1, newEntity);
			// con FlxPoint no funciona, por lo que guardemoslo como la suma de sus ejes
			entitiesDictionary.set(mouseX + mouseY, entitiesPositions.length - 1);

			if (actualEntity == 0 && !levelHasPlayer)
				levelHasPlayer = true;
		}

		if (FlxG.mouse.justPressedRight)
		{
			var entityPos:Int = mouseX + mouseY; // ID improvisado
			if (entitiesDictionary.exists(entityPos))
			{
				var entityIndex:Int = entitiesDictionary.get(entityPos);
				var entity = levelEntities.members[entityIndex];
				var entityData = entitiesPositions[entityIndex];

				if (entityData.type == 0)
					levelHasPlayer = false;

				levelEntities.remove(entity);
				entity.destroy();

				entitiesPositions.remove(entityData);
				entitiesDictionary.remove(entityPos);
			}
		}
		#end
	}

	function changeEntityPreview()
	{
		if (actualEntity >= MAX_ENTITIES)
			actualEntity = 0;

		if (actualEntity < 0)
			actualEntity = MAX_ENTITIES - 1;

		switch (actualEntity)
		{
			case 0:
				currentEntityName.text = "PLAYER";
			case 1:
				currentEntityName.text = "ENEMY - PICKY";
			case 2:
				currentEntityName.text = "COIN";
			case 3:
				currentEntityName.text = "FLAG";
		}
		loadEntity(currentEntity);
	}

	/*
		Entity ID:
		0 -> Player
		1 -> Enemy
		2 -> Coin
		3 -> Flag
	 */
	function loadEntity(entity:FlxSprite)
	{
		switch (actualEntity)
		{
			case 0:
				entity.loadGraphic(Paths.getImage('player'), true, 12, 24);
			case 1:
				entity.loadGraphic(Paths.getImage('picky'), true, 12, 12);
			case 2:
				entity.loadGraphic(Paths.getImage('items/coin'), true, 12, 12);
			case 3:
				entity.loadGraphic(Paths.getImage('items/flag'), true, 24, 48);
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

		tilemapUI = new FlxGroup();
		entityUI = new FlxGroup();
		entitiesDictionary = new Dictionary<Int, Int>();

		backParallax = new BackParallax(Paths.getImage('parallax/mountain'), 65, 0xFF005100, true);
		add(backParallax);

		// UI stuff
		uiBorder = new FlxSprite(0, FlxG.height - 16);
		uiBorder.makeGraphic(FlxG.width, 16, 0xFF0163C6);
		add(uiBorder);

		onEditorCreate();
		onEntityCreate();

		sprLayers = new FlxSprite(Game.WIDTH - 40, uiBorder.y - 9);
		sprLayers.loadGraphic(Paths.getImage("layers"), true, 32, 9);
		add(sprLayers);

		editorText = new FlxText(Game.WIDTH - 102, Game.HEIGHT - 18, 100, "LEVEL EDITOR");
		editorText.setFormat("assets/fonts/Toy.ttf", 16, RIGHT);
		add(editorText);

		blackBackground = new FlxSprite();
		blackBackground.makeGraphic(Game.WIDTH, Game.HEIGHT, 0x99000000);
		blackBackground.visible = false;
		add(blackBackground);

		// Configurar cámaras
		uiBorder.cameras = [uiCamera];
		sprLayers.cameras = [uiCamera];
		editorText.cameras = [uiCamera];
		blackBackground.cameras = [uiCamera];

		FlxG.camera.bgColor = 0xFF64A5FF;
		changeState(Tilemap);
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
			default:
		}

		if (FlxG.mouse.getPosition().y >= sprLayers.y)
		{
			if (uiBorder.alpha > .5)
				uiBorder.alpha = sprLayers.alpha -= .1;
		}
		else
		{
			if (uiBorder.alpha < 1)
				uiBorder.alpha = sprLayers.alpha += .1;
		}

		if (FlxG.keys.justPressed.U)
			uiCamera.visible = !uiCamera.visible;

		if (canChangeState)
		{
			if (FlxG.keys.justPressed.E)
				changeState(Entity);

			if (FlxG.keys.justPressed.T)
				changeState(Tilemap);
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.mouse.visible = false;
			FlxG.switchState(new MenuState());
		}

		FlxG.watch.addQuick("Mouse X", mouseX);
		FlxG.watch.addQuick("Mouse Y", mouseY);
		FlxG.watch.addQuick("Mouse Sel. X", mouseX * Game.TILE_SIZE);
		FlxG.watch.addQuick("Mouse Sel. Y", mouseY * Game.TILE_SIZE);
		#end
	}

	function changeState(state:EditorMode)
	{
		switch (state)
		{
			case Tilemap:
				tilemapUI.visible = true;
				entityUI.visible = false;
				setLayerTilePreview();
				editorText.text = "LEVEL EDITOR";
			case Entity:
				tilemapUI.visible = false;
				entityUI.visible = true;
				sprLayers.animation.frameIndex = 3;
				editorText.text = "ENTITY EDITOR";
			default:
		}
		editorState = state;
	}
}
