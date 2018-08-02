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
import tannus.stream.Stream;

import haxe.ds.Option;
import haxe.ds.Either;
import haxe.Constraints.Function;
import haxe.extern.EitherType;
import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Context;

import Slambda.fn;

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

class StreamBase<Item, Quality> implements StreamObject<Item, Quality> {
    public function next():Next<Step<Item, Quality>> {
        throw 'not implemented';
    }

    public function forEach<Safety>(handler: Handler<Item, Safety>):Next<Conclusion<Item, Safety, Quality>> {
        throw 'not implemented';
    }

    public function destroy() {
        //
    }

    public function decompose(into: Array<Stream<Item, Quality>>) {
        if (!depleted)
            into.push( this );
    }

    public function append(s: Stream<Item, Quality>):Stream<Item, Quality> {
        return depleted ? s : CompoundStream.of([this, s]);
    }

    public function prepend(s: Stream<Item, Quality>):Stream<Item, Quality> {
        return depleted ? s : CompoundStream.of([s, this]);
    }

    public function regroup<O>(regrouper: Regrouper<Item, O, Quality>):Stream<O, Quality> {
        return new RegroupStream(this, regrouper);
    }

    public function map<O>(m: Mapping<Item, O, Quality>):Stream<O, Quality> {
        return regroup( m );
    }

    public function filter(f: Filter<Item, Quality>):Stream<Item, Quality> {
        return regroup( f );
    }

    public function reduce<Safety, Acc>(initial:Acc, reducer:Reducer<Item, Safety, Acc>):Next<Reduction<Item, Safety, Quality, Acc>> {
        return new Promise<Reduction<Item, Safety, Quality, Acc>>(function(accept, reject) {
            forEach(function(item) {
                return reducer.apply(initial, item).map(function(o):Handled<Safety> {
                    return switch o {
                        case Progress(v):
                            initial = v;
                            Resume;

                        case Crash(e):
                            Clog(e);
                    }
                });
            }).then(function(c) {
                switch c {
                    case Failed(e):
                        accept(Reduction.Failed(e));

                    case Depleted:
                        accept(Reduced(initial));

                    case Halted(_):
                        throw 'assert';

                    case Clogged(e, rest):
                        accept(Crashed(e, rest));
                }
            });
        });
    }

    public function blend(other: Stream<Item, Quality>):Stream<Item, Quality> {
        return
            if ( depleted )
                other;
            else
                new BlendStream(this, other);
    }

    public var depleted(get, never):Bool;
    function get_depleted() return false;
}
