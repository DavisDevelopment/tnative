package tannus.io;

import haxe.io.Bytes;
import tannus.io.Ptr;
import tannus.io.ByteArray;
import tannus.ds.Object;

import tannus.io.struct.StructField in Field;
import tannus.io.struct.StructFieldType in FType;

class Struct {
    /* Constructor Function */
    public function new():Void {
        fields = new Array();
        _data = Bytes.alloc( 0 );
        buffer = Ptr.create( _data );
    }
    
    /**
      * Add a new Field to [this] Structure
      */
    public function addField(name:String, type:FType):Void {
        var f = new Field(name, type, totalSize(), buffer);
        fields.push( f );
        _data = Bytes.alloc(_data.length + f.length);
        _data.fill(0, _data.length, 0x0000);
    }
    
    /**
      * Write to a single Field
      */
    public function set(name:String, value:Dynamic):Dynamic {
        var nf:Null<Field> = getFieldO(name);
        if (nf == null)
            throw 'NameError: No Field named "$name"!';
        else {
            var f:Field = cast nf;
            f.write( value );
            return f.read();
        }
    }
    
    /**
      * Read the value of a single Field
      */
    public function get(name : String):Dynamic {
        var nf:Null<Field> = getFieldO(name);
        if (nf == null)
            throw 'NameError: No Field named "$name"!';
        else {
            var f:Field = cast nf;
            return f.read();
        }
    }
    
    /**
      * Obtain a Pointer to a field of [this] Struct
      */
    public function field(name : String):Ptr<Dynamic> {
        var ref:Ptr<Dynamic> = new Ptr(get.bind(name), set.bind(name, _));
        return ref;
    }
    
    /**
      * Obtain a Field by name
      */
    private function getFieldO(n : String):Null<Field> {
        for (f in fields)
            if (f.name == n)
                return f;
        return null;
    }
    
    private inline function totalSize():Int {
        var s:Int = 0;
        for (f in fields)
            s += f.length;
        return s;
    }
    
    /**
      * Write to multiple Fields at once
      */
    public function write(data : Object):Bytes {
        var i:Int = 0;
        for (f in fields) {
            f.write( data[f.name] );
            i += f.length;
        }
        return buffer._;
    }
    
    /**
      * Read [this] Structure as a Object
      */
    public function read():Object {
        var o:Object = {};
        var i:Int = 0;
        for (f in fields) {
            var v:Dynamic = f.read();
            o[f.name] = v;
            i += f.length;
        }
        return o;
    }
    
    /**
      * Current binary-representation of [this] Struct
      */
    public var bytes(get, set):ByteArray;
    private inline function get_bytes():ByteArray {
        return _data;
    }
    private inline function set_bytes(v : ByteArray):ByteArray {
        return (_data = v);
    }
    
    private var fields : Array<Field>;
    private var _data : Bytes;
    private var buffer : Ptr<Bytes>;
}