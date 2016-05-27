package tannus.crypto;

import tannus.io.*;
import tannus.ds.*;

import haxe.io.BytesOutput;
import haxe.crypto.BaseCode;
import haxe.ds.Vector;
import haxe.Utf8;

import Math.*;
import Std.*;
import tannus.math.TMath.*;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

class Tea {
    /* Constructor Function */
    public function new(?k : ByteArray):Void {
        key = (k != null ? k : new ByteArray());
        blockSize = 32;
    }
    
/* === Instance Methods === */

    /* encrypt the given ByteArray */
    //public function encrypt(text:ByteArray, key:ByteArray):ByteArray {
        //key = key.slice(0, 16);
        //var v = toLongs( text );
        //var k = toLongs( key );
        //v = encode(v, k);
        //var cipher = fromLongs( v );
        //return toBase64( cipher );
    //}
    
    //public function encode(data:ByteArray, key:ByteArray):ByteArray {
        //if (data.length < 2)
            //data.push( 0 );
        //var n:Int = data.length;
        //var z:Int = data[n - 1];
        //var y:Int = data[0];
        //var delta:Int = 0x9E3779B9;
        //var mx:Int;
        //var e:Int;
        //var q:Int = floor(6 + 52 / n);
        //var sum:Int = 0;
        
        //while (q-- > 0) {
            //sum += delta;
            //e = sum >>> 2 & 3;
            //var p:Int = 0;
            //while (p < n) {
                //y = data[(p + 1) % n];
                //mx = ((z >>> 5 ^ y << 2) + (y >>> 3 ^ z << 4) ^ (sum ^ y) + (key[p & 3 ^ e] ^ z));
                //z = data[p].asint += mx;
                //p++;
            //}
        //}
        
        //return data;
    //}

    /* convert a piece of data to a Vector of Ints */
    public function toLongs(s : ByteArray):Array<Int> {
        s = s.copy();
	while (s.length % 4 != 0)
	    s.push( 0 );
            
        var list:Vector<Int> = new Vector(ceil(s.length / 4));
        for (index in 0...list.length) {
            var i:Int = (index * 4);
            list.set(index, [
                s[i],
                s[i+1] << 8,
                s[i+2] << 16,
                s[i+3] << 24
            ].sum());
        }
        return list.toArray();
    }
    
    /* convert a Vector of longs to a ByteArray */
    public function fromLongs(list : Array<Int>):ByteArray {
        var res:ByteArray = new ByteArray();
        for (i in 0...list.length) {
            res.push(list[i] & 0xFF);
            res.push(list[i] >>> 8 & 0xFF);
            res.push(list[i] >>> 16 & 0xFF);
            res.push(list[i] >>> 24 & 0xFF);
        }
        return res;
    }
    
    public inline function toUtf8(data : ByteArray):ByteArray {
        //return ByteArray.ofString(Utf8.encode(data.toString()));
        return data.copy();
    }
    
    public inline function fromUtf8(data : ByteArray):ByteArray {
        //return ByteArray.ofString(Utf8.decode(data.toString()));
        return data.copy();
    }
    
    public inline function toBase64(d : ByteArray):ByteArray {
        return ByteArray.ofString(d.toBase64());
    }
    
    public inline function fromBase64(d : ByteArray):ByteArray {
        return ByteArray.fromBase64(d.toString());
    }
    
/* === Instance Fields === */

    public var key : ByteArray;
    public var blockSize : Int;
}
