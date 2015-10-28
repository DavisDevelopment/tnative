package tannus.io.struct;

import haxe.io.Bytes;

import tannus.io.Ptr;
import tannus.ds.TwoTuple;
import tannus.ds.ThreeTuple;

import tannus.io.struct.StructFieldType in FType;

abstract StructField (SField) {
    public inline function new(name:String, type:FType, offs:Int, bref:Ptr<Bytes>):Void {
        var _fio = new FieldIO(0, name, type);
        this = new SField(_fio, new BytesSlice(offs, _fio.size(), bref));
    }
    
/* == Instance Methods === */

    /**
      * Get the value of [this] Field
      */
    public inline function read():Dynamic {
        return this.one.read( this.two );
    }
    
    /**
      * Set the value of [this] Field
      */
    public inline function write(value : Dynamic):Void {
        this.one.write(this.two, value);
    }
    
/* == Instance Fields === */

    public var name(get, never):String;
    private inline function get_name() return (this.one.name);
    
    public var type(get, never):FType;
    private inline function get_type() return (this.one.type);
    
    public var length(get, never):Int; 
    private inline function get_length() return (this.one.size());
    
    public var offset(get, never):Int;
    private inline function get_offset() return (this.two.offset);
}

/**
  * Abstract which handles Field-Related IO
  */
abstract FieldIO (Fio) {
    /* Constructor Function */
    public inline function new(i:Int, name:String, type:FType):Void {
        this = new Fio(i, name, type);
    }
    
/* === Instance Methods === */
    
    /**
      * Read [this] Field from [b]
      */
    public function read(b : BytesSlice):Null<Dynamic> {
        switch (type) {
            case TBool:
                var n:Int = b.get(0);
                return (n > 1);
                
            case TInt, TFloat:
                try {
                    var num:Float = (type==TInt?b.get(0):b.getFloat(0)); 
                    return num;
                } catch (err : Dynamic) return null;
                
            case TString(len):
                var str:String = '';
                for (x in 0...(len)) {
                    var c:Int = b.get(x);
                    str += String.fromCharCode( c );
                }
                str = StringTools.replace(str, '\u0000', '');
                return str;
        }
    }
    
    /**
      * Write data onto [this] Field, stored in [b]
      */
    public function write(b:BytesSlice, val:Dynamic):Void {
        switch (type) {
            case TBool:
                b.set(0, (val==true?2:1));
                
            case TInt, TFloat:
                switch (type) {
                    case TInt:
                        b.set(0, cast val);
                        
                    case TFloat:
                        b.setFloat(0, cast val);
                        
                    default:
                        null;
                }
                
            case TString( len ):
                var str:String = (cast val);
                for (xi in 0...len) {
                    var code:Null<Int> = str.charCodeAt(xi);
                    if (code == null)
                        code = 0x0000;
                    b.set(xi, code);
                }
        }
    }
    
    /**
      * Query the 'size' of [this] Field
      */
    public inline function size():Int {
        return (switch(type) {
            case TBool: 1;
            case TInt: 1;
            case TFloat: 4;
            case TString(s): s;
        });
    }
    
/* === Instance Fields === */

    /* The index of [this] Field */
    public var index(get, set):Int;
    private inline function get_index() return (this.one);
    private inline function set_index(i : Int) return (this.one = i);
    
    /* The name of [this] Field */
    public var name(get, never):String;
    private inline function get_name() return (this.two);
    
    /* The type of [this] Field */
    public var type(get, never):FType;
    private inline function get_type() return (this.three);
    
    private static inline var INT:Int = 1;
    private static inline var FLOAT:Int = 4;
    private static inline var DOUBLE:Int = 8;
}

private typedef Fio = ThreeTuple<Int, String, FType>;
private typedef SField = TwoTuple<FieldIO, BytesSlice>;