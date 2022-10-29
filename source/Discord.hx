package;

#if (cpp && desktop)
import Sys.sleep;
import discord_rpc.DiscordRpc;
import sys.thread.Thread;
#end

enum State
{
	Title;
	Level;
	Shop;
	DemoEnd;
}

#if (cpp && desktop)
class Discord
{
	public static var hasStarted:Bool = false;

	public function new()
	{
		DiscordRpc.start({
			clientID: "838937204298088498",
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		trace("Discord started!");

		while (true)
		{
			DiscordRpc.process();
			sleep(2);
		}

		DiscordRpc.shutdown();
	}

	static function onReady()
	{
		DiscordRpc.presence({
			details: 'In the Title Screen',
			state: null,
			largeImageKey: 'icon'
		});
	}

	static function onError(_code:Int, _message:String)
	{
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		trace('Disconnected! $_code : $_message');
	}

	public static function init()
	{
		// Pues sí... estuve viendo en el código de FNF.
		Thread.create(() -> new Discord());
		hasStarted = true;
		trace("Discord inicializado!");
	}

	public static function close()
	{
		DiscordRpc.shutdown();
	}

	public static function changePresence(_state:State, ?player:Int, ?initialTime:Float)
	{
		switch (_state)
		{
			case Title:
				DiscordRpc.presence({
					details: 'In the Title Screen',
					state: null,
					largeImageKey: 'icon'
				});
			case Level:
				DiscordRpc.presence({
					details: 'Playing Level ${PlayState.LEVEL}',
					state: 'Coins: ${PlayState.MONEY}',
					largeImageKey: 'icon', // 'icon$player',
					startTimestamp: Std.int(initialTime / 1000)
				});
			case Shop:
				DiscordRpc.presence({
					details: 'In the Shop',
					state: 'Coins: ${PlayState.MONEY}',
					largeImageKey: 'icon'
				});
			case DemoEnd:
				DiscordRpc.presence({
					details: 'Demo finished!',
					state: 'Coins: ${PlayState.MONEY}',
					largeImageKey: 'icon'
				});
		}
	}
}
#end
