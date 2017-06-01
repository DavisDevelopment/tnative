package tannus.ds.dict;

import tannus.ds.IComparable;
import tannus.io.Ptr;
import haxe.ds.BalancedTree;

import haxe.Serializer;
import haxe.Unserializer;

class FloatDict<T> implements IDict<Float, T> {
    /* Constructor Function */
    public function new():Void {
        t = new FloatTree();
    }

/* === Instance Methods === */

    public inline function get(n : Float):Null<T> return t.get( n );
    public function set(n:Float, v:T):T {
        t.set(n, v);
        return get( n );
    }
    public function reference(n : Float):Ptr<T> {
        return new Ptr(t.get.bind( n ), set.bind(n, _));
    }
    public inline function exists(n : Float):Bool { return t.exists( n ); }
    public inline function remove(n : Float):Bool return t.remove( n );
    public inline function iterator():Iterator<T> return t.iterator();
    public inline function keys():Iterator<Float> return t.keys();
    public inline function pairs():Iterator<Pair<Float, T>> {
        return cast new FloatDictIter( this );
    }

    @:keep
    public function hxSerialize(s : Serializer):Void {
        inline function w(x:Dynamic) s.serialize( x );
        var pl = [for (pair in pairs()) pair];
        w( pl.length );
        for (p in pl) {
            w( p.key );
            w( p.value );
        }
    }

    @:keep
    public function hxUnserialize(u : Unserializer):Void {
        inline function v():Dynamic return u.unserialize();
        var count:Int = v();
        t = new FloatTree();
        for (i in 0...count) {
            set(v(), v());
        }
    }


/* === Instance Fields === */

    private var t : FloatTree<T>;
}

class FloatTree<T> extends BalancedTree<Float, T> {
	override function compare(x:Float, y:Float):Int {
		return Reflect.compare(x, y);
	}
}

class FloatDictIter<T> {
    private var d:FloatDict<T>;
    private var i:Iterator<Float>;
    public function new(d : FloatDict<T>):Void {
        this.d = d;
        this.i = d.keys();
    }
    public inline function hasNext():Bool return i.hasNext();
    public function next():Pair<Float, T> {
        var k = i.next();
        return new Pair(k, d.get( k ));
    }
}
