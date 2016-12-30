package tannus.ds;

import tannus.ds.dict.*;

import haxe.macro.Expr;
import haxe.macro.Context;

using tannus.macro.MacroTools;
using haxe.macro.ExprTools;

@:multiType
@:forward
abstract Dict<K, V> (IDict<K, V>) {
	/* Constructor Function */
	public function new():Void;

	@:arrayAccess
	public inline function get(key : K):Null<V> return this.get( key );
	@:arrayAccess
	public inline function set(key:K, value:V):V return this.set(key, value);

	@:to
	public static inline function toStringDict<K:String, V>(v : IDict<K, V>):StringDict<V> {
		return new StringDict();
	}

	@:to
	public static inline function toIntDict<K:Int, V>(v : IDict<K, V>):IntDict<V> {
		return new IntDict();
	}

	@:to
	public static inline function toEnumValueDict<K:EnumValue, V>(v : IDict<K, V>):EnumValueDict<K, V> {
		return new EnumValueDict();
	}

	@:to
	public static inline function toIComparableDict<K:IComparable<K>, V>(v : IDict<K, V>):IComparableDict<K, V> {
		return new IComparableDict();
	}

	@:to
	public static inline function toComparableDict<K:Comparable<K>, V>(v : IDict<K, V>):ComparableDict<K, V> {
		return new ComparableDict();
	}
}
