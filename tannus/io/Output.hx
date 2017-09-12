package tannus.io;

import haxe.io.Output as Out;

class Output <T:Out> {
    private var o : T;
    public function new(o : T):Void {
        this.o = o;
    }

    public var bigEndian(get, set):Bool;
    private inline function get_bigEndian() return o.bigEndian;
    private inline function set_bigEndian(v) return (o.bigEndian = v);

    public function close():Void o.close();
    public function flush():Void o.flush();
    public function prepare(nbytes:Int):Void o.prepare(nbytes);
    public function write(s : ByteArray):Void o.write(s);
    public function writeByte(c : Int):Void o.writeByte( c );
    public function writeBytes(s:ByteArray, pos:Int, len:Int):Int return o.writeBytes(s, pos, len);
    public function writeDouble(x : Float):Void o.writeDouble( x );
    public function writeFloat(x : Float):Void o.writeFloat( x );
    public function writeFullBytes(s:ByteArray, pos:Int, len:Int):Void return o.writeFullBytes(s, pos, len);
    public function writeInt16(x : Int):Void o.writeInt16( x );
    public function writeInt24(x : Int):Void o.writeInt24( x );
    public function writeInt32(x : Int):Void o.writeInt32( x );
    public function writeInt8(x : Int):Void o.writeInt8( x );
    public function writeString(s : String):Void o.writeString( s );
    public function writeUInt16(x : Int):Void o.writeUInt16( x );
    public function writeUInt24(x : Int):Void o.writeUInt24( x );

    public inline function writeInput<I:haxe.io.Input>(i:Input<I>, ?bufsize:Int):Void {
        @:privateAccess
        o.writeInput(i.i, bufsize);
    }
}
