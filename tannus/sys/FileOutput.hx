package tannus.sys;

import tannus.io.*;

#if (js && node)
import tannus.sys.node.NodeFileOutput as FOut;
import tannus.sys.FileSeek;
#else
import sys.io.FileOutput as FOut;
import sys.io.FileSeek;
#end

import haxe.io.Bytes;

class FileOutput extends Output<FOut> {
    public inline function seek(p:Int, pos:FileSeek):Int {
        o.seek(p, pos);
        return tell();
    }
    public inline function tell():Int return o.tell();
}

