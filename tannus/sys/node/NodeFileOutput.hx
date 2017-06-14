package tannus.sys.node;

import haxe.io.Output;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;

import tannus.sys.FileSeek;

import tannus.node.*;
import tannus.node.Fs;

class NodeFileOutput extends Output {
    /* Constructor Function */
    public function new(path : String):Void {
        this.path = path;
        this.fid = Fs.openSync(path, 'w');
        b = new BytesBuffer();
    }

/* === Instance Methods === */

    override function writeByte(c : Int):Void {
        b.addByte( c );
        _p++;
    }

    override function flush():Void {
        if (b.length == 0)
            return ;

        var buffr = cast(tannus.io.ByteArray.fromBytes(b.getBytes()), tannus.io.impl.NodeBinary).getData();
        Fs.writeSync(fid, buffr, 0, buffr.length, _p);
        b = new BytesBuffer();
    }

    override function close():Void {
        flush();
        Fs.closeSync( fid );
    }

    public function seek(p:Int, seek:FileSeek):Int {
        var np:Int = p;
        switch ( seek ) {
            case FileSeek.SeekBegin:
                null;

            case FileSeek.SeekCur:
                np = (_p + p);

            case FileSeek.SeekEnd:
                np = (FileSystem.stat(path).size - p);
        }
        _p = np;
        return _p;
    }

    public function tell():Int {
        return _p;
    }

/* === Instance Fields === */

    private var path : String;
    private var fid : Int;
    private var b : BytesBuffer;
    private var _p : Int = 0;
}
