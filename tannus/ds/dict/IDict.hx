package tannus.ds.dict;

import tannus.io.Ptr;

import haxe.Serializer;
import haxe.Unserializer;

interface IDict<K, V> {
	//function new():Void;
	function get(key : K):Null<V>;
	function set(key:K, value:V):V;
	function reference(key : K):Ptr<V>;
	function exists(key : K):Bool;
	function remove(key : K):Bool;
	function iterator():Iterator<V>;
	function keys():Iterator<K>;
	function pairs():Iterator<Pair<K, V>>;

	function hxSerialize(s : Serializer):Void;
	function hxUnserialize(u : Unserializer):Void;
}
