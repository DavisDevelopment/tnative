package tannus.sys;

import tannus.io.*;

#if (js && node)
import tannus.sys.node.NodeFileInput as FIn;
import tannus.sys.FileSeek;
#else
import sys.io.FileInput as FIn;
import sys.io.FileSeek;
#end

class FileInput extends Input<FIn> {
    public inline function eof():Bool return i.eof();
    public inline function tell():Int return i.tell();
    public inline function seek(p:Int, pos:FileSeek):Int {
        i.seek(p, pos);
        return tell();
    }
}
