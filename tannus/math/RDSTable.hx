package tannus.math;

import tannus.io.*;
import tannus.ds.*;
import tannus.async.*;
import tannus.sys.Path;
import tannus.geom2.*;
import tannus.math.*;

import haxe.Serializer;
import haxe.Unserializer;

import Slambda.fn;
import tannus.math.TMath.*;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;
using tannus.FunctionTools;
using tannus.html.JSTools;

class RDSTable<T> {
    public function new(?r: Random) {
        table = new Array();
        this.r = (r != null ? r : new Random());
    }

    public inline function clear() {
        this.table = new Array();
    }

    public inline function add(item:T, weight:Float=1.0, quantity:Int=1) {
        table.push(new RDSNode(item, weight, quantity));
    }

    public function choose():Null<T> {
        if (table.empty()) {
            return null;
        }

        var totalWeight:Float = 0;
        for (x in table) {
            totalWeight += x.weight;
        }

        var choice:Int = 0;
        var randomNumber:Int = floor(r.randfloat(0.0, totalWeight));
        var weight:Float = 0;
        for (i in 0...table.length) {
            var item = table[i];
            if (item.quantity <= 0) continue;
            weight += item.weight;
            if (randomNumber <= weight) {
                choice = i;
                break;
            }
        }

        var chosenItem = table[choice];
        return chosenItem.item;
    }

    private var table: Array<RDSNode<T>>;
    private var r: Random;
}

class RDSNode<T> {
    public var item: T;
    public var weight: Float;
    public var quantity: Int;

    public inline function new(v:T, w:Float=1.0, n:Int=1) {
        item = v;
        weight = w;
        quantity = n;
    }
}
