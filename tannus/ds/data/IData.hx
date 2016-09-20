package tannus.ds.data;

interface IData<T> {
	function get(i:Int):Null<T>;
	function set(i:Int, v:Null<T>):Null<T>;
	function has(i:Int):Bool;
	function add(v:T):Int;
	function fill(v:T):Void;
	function sets(vals:Array<T>):Void;
	//function reset(d : Vector<T>):Void;

	var capacity(get, never):Int;
	var length(get, never):Int;
	var full(get, never):Bool;
}
