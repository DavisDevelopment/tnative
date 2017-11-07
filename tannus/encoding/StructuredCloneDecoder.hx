package tannus.encoding;

import tannus.ds.*;

import tannus.encoding.StructuredCloneCompatible;

import Std.*;
import tannus.math.TMath.*;
import tannus.encoding.StructuredCloneTools.*;

import js.html.*;

using Slambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;
using tannus.html.JSTools;
using tannus.encoding.StructuredCloneTools;

class StructuredCloneDecoder {
    /* Constructor Function */
    public function new():Void {

    }

/* === Instance Methods === */

    /**
      * decode a value
      */
    public function decode(v : Dynamic):Dynamic {
        if (v == null || v.isStructureCloneCompatible()) {
            return v;
        }
        else {
            if (cache != null) {
                cache = new Dict();
            }
            if (nextCacheKey != null) {
                nextCacheKey = 0;
            }
            return decodeValue( v );
        }
    }

    /**
      * decode a value
      */
    private function decodeValue(v : Object):Dynamic {
        if (v == null || v.isStructureCloneCompatible()) {
            return v;
        }
        else if (v.isClassNode()) {
            var node = v.asClassNode();
            trace( node );
            var type:Null<Class<Dynamic>> = Type.resolveClass( node.type );
            if (type == null) {
                throw 'Error: Could not resolve type ${node.type}';
            }
            else {
                var inst:Dynamic = Type.createEmptyInstance( type );
                var o:Object = new Object( inst );
                if (o[DECODEMETHODKEY] != null) {
                    //o.call(DECODEMETHODKEY, [decodeValue(node.data)]);
                    inst.nag(DECODEMETHODKEY).call(inst, decodeValue( node.data ));
                }
                else {
                    var data:Object = decodeValue( node.data );
                    for (key in data.keys) {
                        o[key] = data[key];
                    }
                }
                cacheValue(v, o);
                return inst;
            }
        }
        else if ((v is Array<Dynamic>)) {
            var va:Array<Dynamic> = cast v;
            var key = cacheKeyFor( va );
            if (key == null) {
                var copy:Array<Dynamic> = va.map( decodeValue );
                cacheValue(va, copy);
                return copy;
            }
            else {
                return cache[key].decoded;
            }
        }
        else if (v.isCacheNode()) {
            var node = v.asCacheNode();
            initCache();
            var entry = cache[node.index];
            if (entry == null) {
                throw 'CacheError: CacheNode referred to nonexistent object';
            }
            else {
                return entry.decoded;
            }
        }
        
        else if (v.isEnumNode()) {
            var node = v.asEnumNode();
            var type:Null<Enum<Dynamic>> = Type.resolveEnum( node.type );
            if (type == null) {
                throw 'Error: Could not resolve type ${node.type}';
            }
            else {
                var ev:Dynamic;
                var ed:Array<Dynamic> = node.data.map( decodeValue );
                if (node.name != null) {
                    ev = type.createByName(node.name, ed);
                }
                else if (node.index != null) {
                    ev = type.createByIndex(node.index, ed);
                }
                else {
                    throw 'Error: Neither name nor index was provided for EnumValue<${type.getName()}>';
                }
                cacheValue(v, ev);
                return ev;
            }
        }
        else {
            var copy:Object = {};
            for (key in v.keys) {
                copy[key] = decodeValue(v[key]);
            }
            cacheValue(v, copy);
            return copy;
        }
    }

    /**
      * cache the given value
      */
    private function cacheValue(value:Dynamic, decoded:Dynamic):Void {
        initCache();
        cache[nextCacheKey++] = {value:value, decoded:decoded};
    }

    /**
      * check if [v] is in the cache
      */
    private function isCached(v : Dynamic):Bool {
        initCache();
        return (cacheKeyFor( v ) != null);
    }

    /**
      * get the cache key for [v]
      */
    private function cacheKeyFor(x : Dynamic):Null<Int> {
        initCache();
        for (i in cache.keys()) {
            var y:Dynamic = cache[i].value;
            if (x == y) {
                return i;
            }
        }
        return null;
    }

    /**
      * ensure that the [cache] system is initialized
      */
    private inline function initCache():Void {
        if (cache == null) {
            cache = new Dict();
        }
        if (nextCacheKey == null) {
            nextCacheKey = 0;
        }
    }

/* === Instance Fields === */

    private var cache : Dict<Int, {value:Dynamic, decoded:Dynamic}>;
    private var nextCacheKey : Int;

/* === Static Methods === */

    public static function run(x : Dynamic):Dynamic {
        return (new StructuredCloneDecoder().decode( x ));
    }
}
