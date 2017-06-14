package tannus.sys;

import tannus.io.*;

#if (js && node)
import tannus.sys.node.NodeFileInput as FIn;
import tannus.sys.FileSeek;
#else
import sys.io.FileInput as FIn;
import sys.io.FileSeek;
#end

class FileInput {
    private var i : FIn;
    public function new(i : FIn):Void {
        this.i = i;
    }

    public inline function close():Void i.close();
    public inline function read(nbytes:Int):ByteArray return i.read(nbytes);
    public inline function readAll(?bufsize:Int):ByteArray return i.readAll(bufsize);
    public inline function readByte():Byte return i.readByte();
    public function readBytes(s:ByteArray, pos:Int, len:Int):Int {
        var bytesRead:Int = 0;
        for (n in pos...(pos+len)) {
            s[n] = readByte();
            bytesRead++;
        }
        return bytesRead;
    }
    public inline function readDouble():Float return i.readDouble();
    public inline function readFloat():Float return i.readFloat();
    public inline function readFullBytes(s:ByteArray, pos:Int, len:Int):Void {
        readBytes(s, pos, len);
    }
    public inline function readInt16():Int return i.readInt16();
    public inline function readInt24():Int return i.readInt24();
    public inline function readInt32():Int return i.readInt32();
    public inline function readInt8():Int return i.readInt8();
    public inline function readLine():String return i.readLine();
    public inline function readString(len:Int):String return i.readString(len);
    public inline function readUInt16():Int return i.readUInt16();
    public inline function readUInt24():Int return i.readUInt24();
    public inline function readUntil(end : Byte):String return i.readUntil( end );
    public inline function eof():Bool return i.eof();
    public inline function tell():Int return i.tell();
    public inline function seek(p:Int, pos:FileSeek):Int {
        i.seek(p, pos);
        return tell();
    }

    public var bigEndian(get, set):Bool;
    private inline function get_bigEndian() return i.bigEndian;
    private inline function set_bigEndian(v) return i.bigEndian = v;
}
