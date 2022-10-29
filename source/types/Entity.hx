package types;

inline var MAX_ENTITIES:Int = 4;

/*
	Entity ID:
	0 -> Player
	1 -> Enemy
	2 -> Coin
	3 -> Flag
 */
typedef Entity =
{
	var type:Int;
	var x:Float;
	var y:Float;
}
