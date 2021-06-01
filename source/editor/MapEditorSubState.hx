package editor;

import flixel.FlxSubState;

class MapEditorSubState extends FlxSubState
{
	public var editorState:MapEditor;

	override public function create()
	{
		super.create();
		bgColor = 0x99000000;

		var menu:Menu = new Menu(10, 30);
		menu.addPage("default", [
			{
				text: "Create a new map",
				event: (_) -> trace("New Map?")
			},
			{
				text: "Test!",
				event: (_) -> trace("Test Map?")
			},
			{
				text: "Export",
				event: (_) -> trace("Export Map?")
			},
			{
				text: "Back to Editor",
				event: (_) ->
				{
					editorState.onMenu = false;
					this.close();
				}
			}
		]);
		menu.gotoPage("default");
		add(menu);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		Input.update();
	}
}
