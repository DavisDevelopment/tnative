package tannus.http;

import tannus.ds.Pair;

//import thx.Tuple;

using Slambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;
using tannus.FunctionTools;
using tannus.ds.IteratorTools;
using tannus.ds.AnonTools;
using tannus.ds.MapTools;
using tannus.ds.DictTools;

abstract QueryString(Map<String, QueryStringValue>) from Map<String, QueryStringValue> to Map<String, QueryStringValue>{
    public static var separator = "&";
    public static var assignment = "=";
    public static var encodeURIComponent = function(s : String) return s.urlEncode().replace("%20", "+");
    public static var decodeURIComponent = function(s : String) return s.urlDecode().replace("+", " ");

    public static function empty():QueryString {
        return new Map();
    }

    /**
      parse a QueryString
     **/
    public static function parseWithSymbols(s:String, separator:String, assignment:String, ?decodeURIComponent:String->String):QueryString {
        return if (null == s) {
            new Map();
        } 
        else {
            if(null == decodeURIComponent)
                decodeURIComponent = QueryString.decodeURIComponent;
            if(s.startsWith("?") || s.startsWith("#"))
                s = s.substring(1);
            s = s.ltrim();
            s.split(separator).reduce(
                function(qs:QueryString, v:String) {
                    var parts = v.split( assignment );
                    if (parts[0] != "") 
                        qs.add(decodeURIComponent(parts[0]), null == parts[1] ? null : decodeURIComponent(parts[1]));
                    return qs;
                },
                (new Map())
            );
        }
    }

    @:from inline public static function parse(s: String):QueryString {
        return parseWithSymbols(s, separator, assignment, decodeURIComponent);
    }

    @:from 
    public static function fromObject(o : {}):QueryString {
        var qs:QueryString = new Map();
        if(!Reflect.isObject( o ))
            throw 'unable to convert $o to QueryString';
        o.pairs().map(function(t) {
            if(Std.is(t.right, Array)) {
                qs.setMany(t.left, (cast t.right : Array<Dynamic>).map.fn('$_'));
            } 
            else {
                qs.set(t.left, '${t.right}');
            }
        });
        return qs;
    }

    @:to 
    public function toObject():{} {
        return this.keys().reduce(function(o: Dynamic, key: String) {
            var v : Array<String> = this.get(key);
            if(v.length == 0)
                Reflect.setField(o, key, null);
            else if(v.length == 1)
                Reflect.setField(o, key, v[0]);
            else
                Reflect.setField(o, key, v);
            return o;
        }, {});
    }

    inline public function isEmpty() : Bool {
        return !this.iterator().hasNext();
    }

    inline public function isEmptyOrMono() : Bool {
        var arr = [for (k in this.keys()) k];
        if(arr.length == 0)
            return true;
        if(arr.length != 1)
            return false;
        return (this.get(arr[0]) : Array<String>).empty();
    }

    inline public function exists(name: String):Bool {
        return this.exists( name );
    }

    inline public function remove(name : String) {
        return this.remove(name);
    }

    /**
      remove a value from the list of values stored under [name]
     **/
    public function removeValue(name:String, value:String):Bool {
        if(!this.exists(name))
            return false;
        return (this.get(name) : Array<String>).remove(value);
    }

    @:arrayAccess
    inline public function get(name: String):QueryStringValue {
        return this.get(name);
    }

    @:arrayAccess
    inline public function aset(name:String, value:String):QueryStringValue {
        return set(name, value).get( name );
    }

    public function set(name : String, value : String) : QueryString {
        this.set(name, [value]);
        return this;
    }

    public function add(name:String, value:String):QueryString {
        var arr:Array<String> = this.get(name);
        if (null == arr) {
            arr = value == null ? [] : [value];
            this.set(name, arr);
        } 
        else if (null != value) {
            arr.push(value);
        }
        return this;
    }

    public function addMany(name:String, values:Iterable<String>):QueryString {
        for (v in values)
            add(name, v);
        return this;
    }

    public function clone():QueryString {
        if (null == this) 
            return null;
        var map = new Map();
        for (key in this.keys())
            map.set(key, (this.get(key).copy() : QueryStringValue));
        return map;
    }

    public function setMany(name:String, values:Array<String>) {
        this.set(name, values);
        return this;
    }

    /**
      convert to a human-readable String with the given Symbols
     **/
    public function toStringWithSymbols(separator:String, assignment:String, ?encodeURIComponent:String -> String) {
        if (null == this)
            return null;

        if (null == encodeURIComponent)
            encodeURIComponent = QueryString.encodeURIComponent;

        return this.keys().map(function(k: String) {
            var vs:Array<String> = this.get(k),
            ek = encodeURIComponent(k);
            if (vs.empty())
                return [ek];
            else {
                return vs.map.fn('$ek$assignment${encodeURIComponent(_)}');
            }
        }).array().flatten().join(separator);
    }

    /**
      test for equality between [this] and [other]
     **/
    @:op(A == B) 
    public function equals(other : QueryString):Bool {
        //var tuples:Array<Tuple2<String, QueryStringValue>> = thx.Maps.tuples((other:Map<String, QueryStringValue>));
        var tuples = pairs();
        for (key in this.keys()) {
            //var t = tuples.find(function(item) return item.left == key);
            var t = tuples.find(item -> item.left == key);
            if (null == t)
                return false;
            if (!(this.get( key ) : Array<String>).equality((t.right : Array<String>)))
                    return false;
            tuples.remove( t );
        }
        return tuples.empty();
    }

    public function pairs():Array<Pair<String, QueryStringValue>> {
        return this.pairs();
    }

    @:to 
    inline public function toString() {
        return toStringWithSymbols(separator, assignment, encodeURIComponent);
    }
}

@:forward(copy)
abstract QueryStringValue(Array<String>) from Array<String> to Array<String> {
    @:to 
    function toString():String {
        return (this == null || this.length == 0) ? null : this.join(",");
    }
}
