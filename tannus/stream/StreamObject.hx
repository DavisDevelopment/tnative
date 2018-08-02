package tannus.stream;

import tannus.ds.dict.DictKey;
import tannus.ds.Pair;
import tannus.ds.Delta;
import tannus.ds.Lazy;
import tannus.ds.Ref;
import tannus.io.Signal;
import tannus.io.VoidSignal;

import tannus.async.Promise;
import tannus.async.Result;
import tannus.async.AsyncError;

import haxe.ds.Option;
import haxe.ds.Either;
import haxe.Constraints.Function;
import haxe.extern.EitherType;
import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Context;

import Slambda.fn;
import tannus.stream.Stream;

using Slambda;
using tannus.ds.ArrayTools;
using tannus.ds.IteratorTools;
using tannus.FunctionTools;
using tannus.async.Result;
using tannus.async.OptionTools;
using tannus.async.Asyncs;
using tannus.stream.Tools;

using haxe.macro.ExprTools; 
using haxe.macro.TypeTools;
using haxe.macro.ComplexTypeTools;
using tannus.macro.MacroTools;

interface StreamObject<Item, Quality> {
/* === Fields === */
    var depleted(get, never): Bool;

/* === Methods === */

    function next():Next<Step<Item, Quality>>;
    function forEach<Safety>(handler: Handler<Item, Safety>):Next<Conclusion<Item, Safety, Quality>>;
    function decompose(into: Array<Stream<Item, Quality>>):Void;
    function append(other: Stream<Item, Quality>):Stream<Item, Quality>;
    function prepend(other: Stream<Item, Quality>):Stream<Item, Quality>;
    function regroup<Ret>(regrouper: Regrouper<Item, Ret, Quality>):Stream<Ret, Quality>;
    function map<Out>(m: Mapping<Item, Out, Quality>):Stream<Out, Quality>;
    function filter(f: Filter<Item, Quality>):Stream<Item, Quality>;
    function reduce<Safety, Acc>(initial:Acc, reducer:Reducer<Item, Safety, Acc>):Next<Reduction<Item, Safety, Quality, Acc>>;
    function blend(other: Stream<Item, Quality>):Stream<Item, Quality>;
}
