package tannus.sys.node;

import haxe.io.Input;
import haxe.io.Bytes;

import tannus.sys.FileSeek;
import tannus.io.ByteArray;

import tannus.node.*;
import tannus.node.Fs;

class NodeFileInput extends haxe.io.Input {
    /* Constructor Function */
    public function new(path : String):Void {
        this.path = path;
        this.fid = Fs.openSync(path, 'r');
        this.flen = FileSystem.stat( path ).size;
        this.pos = 0;
        this.bigEndian = true;
    }

/* === Instance Methods === */

    /**
      * read a single byte
      */
    override function readByte():Int {
        var buf = new Buffer( 1 );
        var bytesread = 
            try {
                Fs.readSync(fid, buf, 0, 1, pos);
            }
            catch (error : Dynamic) {
                if (error.code == 'EOF')
                    throw new haxe.io.Eof();
                else
                    throw haxe.io.Error.Custom( error );
            }
        if (bytesread == 0)
            throw new haxe.io.Eof();
        pos++;
        return buf[0];
    }

    /**
      * read all available data
      */
    override function readAll(?chunksize : Int):Bytes {
        if (chunksize == null)
            chunksize = 1000;
        var buf = Bytes.alloc( chunksize );
        var total = new haxe.io.BytesBuffer();
        try {
            while ( true ) {
                var len = readBytes(buf, 0, chunksize);
                if (len == 0)
                    throw new haxe.io.Eof();
                total.addBytes(buf, 0, len);
            }
        }
        catch (e : haxe.io.Eof) {}
        return total.getBytes();
    }

    /**
      * close the file
      */
    override function close():Void Fs.closeSync( fid );

    /**
      * get the position in the file
      */
    public inline function tell():Int return pos;

    /**
      * check whether the end of the file has been reached
      */
    public inline function eof():Bool {
        return (pos >= flen);
    }

    /**
      * seek to a specified position in the file
      */
    public function seek(p:Int, seek:FileSeek):Int {
        var np:Int = p;
        switch ( seek ) {
            case SeekBegin:
                np = p;

            case SeekCur:
                np = (pos + p);

            case SeekEnd:
                np = (flen + p);
        }
        return (pos = np);
    }

/* === Instance Fields === */

    private var path : String;
    private var fid : Int;
    private var flen : Int;
    private var pos : Int;
}
