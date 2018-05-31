package tannus.ds;

import tannus.ds.Delta;
import tannus.ds.Pair;
import tannus.ds.Stack;
import tannus.ds.Object;

import tannus.io.Ptr;

//import haxe.Constraints.IMap;
//import haxe.ds.StringMap;
//import Map.IMap;
import tannus.ds.dict.*;

import haxe.macro.Expr;
import haxe.macro.Context;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.ds.MapTools;
using tannus.FunctionTools;
using tannus.ds.AnonTools;

class DictTools {
    /**
      get an Array of key => value pairs
     **/
    public static inline function kvpairs<K:DictKey, V>(d: Dict<K, V>):Array<Pair<K, V>> {
        return [for (t in d.pairs()) new Pair(t.key, t.value)];
    }

    public static function copy<K:DictKey, V>(d: Dict<K, V>):Dict<K, V> {
        return kvpairs( d ).reduce(function(c:Dict<K, V>, t:Pair<K, V>) {
            c[t.left] = t.right;
            return c;
        }, new Dict());
    }
}
