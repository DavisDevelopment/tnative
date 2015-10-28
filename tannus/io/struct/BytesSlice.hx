package tannus.io.struct;

import tannus.ds.TwoTuple;
import tannus.ds.IntRange in Range;
import tannus.io.Ptr;

import haxe.io.Bytes;

abstract BytesSlice (Bs) {
    /* Constructor Function */
    public inline function new(offset:Int, length:Int, b:Ptr<Bytes>):Void {
        this = new TwoTuple(new Range(offset, (offset+length)), createPointer(offset, length, b));
    }
    
/* === Instance Methods === */

    private function affect(f : Bytes->Void):Void {
        var b:Bytes = dat;
        f( b );
        dat = b;
    }
    
    public macro function dew(me:haxe.macro.Expr, action) {
        return macro {
            $me.affect(function(self : haxe.io.Bytes) {
                $action;
            });
        };
    }

    public inline function get(i : Int):Int return dat.get(i);
    public inline function set(i:Int, v:Int) dew(self.set(i, v));
    
    public inline function getFloat(i : Int):Float return (dat.getFloat(i));
    public inline function setFloat(i:Int, f:Float) dew(self.setFloat(i, f));
    
    public inline function getDouble(i : Int):Float return (dat.getDouble(i));
    public inline function setDouble(i:Int, d:Float) dew(self.setDouble(i, d));
    
    public inline function toString():String return dat.toString();
    @:to public inline function toBytes():Bytes return dat;
    
/* === Instance Fields === */

    private var dat(get, set):Bytes;
    private inline function get_dat() return (this.two.get());
    private inline function set_dat(v : Bytes) return (this.two.set( v ));

    /* the length of [this] slice */
    public var length(get, never):Int;
    private inline function get_length() return (this.one.max - this.one.min);
    
    /* the offset of [this] slice */
    public var offset(get, never):Int;
    private inline function get_offset() return (this.one.min);
    
/* === Static Methods === */

    /**
      * Create Sub-Bytes Pointer
      */
    public static function createPointer(i:Int, l:Int, b:Ptr<Bytes>):Ptr<Bytes> {
        /* 'sub'-getter */
        function get_sub():Bytes {
            return (b._).sub(i, l);
        }
        
        /* 'sub'-setter */
        function set_sub(v : Bytes):Bytes {
            (b._).blit(i, v, 0, l);
            return get_sub();
        }
        
        return new Ptr(get_sub, set_sub);
    }
}

private typedef Bs = TwoTuple<Range, Ptr<Bytes>>;