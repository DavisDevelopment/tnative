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

import Slambda.fn;

using Slambda;
using tannus.ds.ArrayTools;
using tannus.ds.IteratorTools;
using tannus.FunctionTools;
using tannus.async.Result;
using tannus.async.OptionTools;
using tannus.async.Asyncs;
using tannus.stream.Tools;

@:forward
abstract Stream<Item, Quality> (StreamObject<Item, Quality>) from StreamObject<Item, Quality> to StreamObject<Item, Quality> {
    public var depleted(get, never): Bool;
    inline function get_depleted() return this.depleted;

/* === Factories === */

    @:from
    public static function flatten<I, Q>(f:Next<Stream<I, Q>>):Stream<I, Q> {
        return new NextStream( f );
    }

    public static function single<I,Q>(i: I):Stream<I, Q> {
        return new Single( i );
    }

    public static function ofError<I, Err>(e: Err):Stream<I, Err> {
        return new ErrorStream( e );
    }

    public static function ofIterator<I, Q>(i: Iterator<I>):Stream<I, Q> {
        return Generator.stream(function next(step) {
            if (i.hasNext()) {
                step(Link(i.next(), Generator.stream(next)));
            }
            else {
                step(End);
            }
        });
    }

/* === Casting === */
}

class ErrorStream<Item, Error> extends StreamBase<Item, Error> {
    var error: Error;
    public function new(error) {
        this.error = error;
    }

    override function next():Next<Step<Item, Error>> {
        return Next.sync(Step.Fail(error));
    }

    override function forEach<Safety>(handler: Handler<Item, Safety>):Next<Conclusion<Item, Safety, Error>> {
        return Next.sync(Conclusion.Failed(error));
    }
}

class Empty<Item, Quality> extends StreamBase<Item, Quality> {
    public function new() {}
    override function next():Next<Step<Item, Quality>> {
        return Next.sync(Step.End);
    }
    override function forEach<Safety>(handler: Handler<Item, Safety>):Next<Conclusion<Item, Safety, Quality>> {
        return Next.sync(Conclusion.Depleted);
    }
    static var inst = new Empty<Dynamic, Dynamic>();
    public static inline function make<Item, Quality>():Stream<Item, Quality> {
        return (cast inst : Stream<Item, Quality>);
    }
}

class Single<Item, Quality> extends StreamBase<Item, Quality> {
    var value: Lazy<Item>;
    public function new(value) {
        this.value = value;
    }

    override function next():Next<Step<Item, Quality>> {
        return Next.sync(Link(value.get(), Empty.make()));
    }

    override function forEach<Safety>(handler: Handler<Item, Safety>):Next<Conclusion<Item, Safety, Quality>> {
        return handler.apply(value).map(function(step):Conclusion<Item, Safety, Quality> {
            return switch step {
                case BackOff: Halted(this);
                case Finish: Halted(Empty.make());
                case Resume: Depleted;
                case Clog(e): Clogged(e, this);
            }
        });
    }
}

class NextStream<I, Q> extends StreamBase<I, Q> {
    var future: Next<Stream<I, Q>>;
    public function new(n) {
        future = n;
    }

    override function next():Next<Step<I, Q>> {
        return future.flatMap(s -> s.next());
    }

    override function forEach<Safety>(handler: Handler<I, Safety>):Next<Conclusion<I, Safety, Q>> {
        return future.derive(function(root, accept, reject) {
            root.then(function(stream) {
                stream.forEach(handler).then(accept, reject);
            }, reject);
        });
    }
}

class Generator<Item, Quality> extends StreamBase<Item, Quality> {
    var upcoming: Next<Step<Item, Quality>>;
    public function new(upcoming) {
        this.upcoming = upcoming;
    }

    override function next():Next<Step<Item, Quality>> {
        return upcoming;
    }

    override function forEach<Safety>(handler: Handler<Item, Safety>) {
        return Next.async(function(cb:Conclusion<Item, Safety, Quality>->Void) {
            upcoming.then(function(step: Step<Item, Quality>) {
                switch step {
                    case Link(v, rest):
                        var rest:Stream<Item, Quality> = rest;
                        handler.apply( v ).then(function(s) {
                            switch s {
                                case BackOff:
                                    cb(Halted(this));

                                case Finish:
                                    cb(Halted(rest));

                                case Resume:
                                    (rest : Stream<Item, Quality>).forEach( handler ).then( cb );

                                case Clog(e):
                                    cb(Clogged(e, this));
                            }
                        });

                    case Fail(e):
                        cb(Failed(e));

                    case End:
                        cb(Depleted);
                }
            });
        });
    }

    public static function stream<I, Q>(step:(Step<I,Q>->Void)->Void) {
        return new Generator(Next.async(step));
    }
}

class CompoundStream<I,Q> extends StreamBase<I, Q> {
    var parts:Array<Stream<I, Q>>;

    public function new(parts) {
        this.parts = parts;
    }

    override function get_depleted():Bool {
        return switch parts.length {
            case 0: true;
            case 1: parts[0].depleted;
            default: false;
        };
    }

    override function next():Next<Step<I, Q>> {
        if (parts.length == 0) {
            return Next.sync(Step.End);
        }
        else {
            return parts[0].next().flatMap(function(v) return switch v {
                case End if (parts.length > 1):
                    parts[1].next();

                case Link(v, rest):
                    var copy = parts.copy();
                    copy[0] = rest;
                    Next.sync(Link(v, new CompoundStream(copy)));

                default:
                    Next.sync(v);
            });
        }
    }

    override function forEach<S>(handler: Handler<I, S>):Next<Conclusion<I, S, Q>> {
        return Next.async(consumeParts.bind(parts, handler, _));
    }

    static function consumeParts<I,Q,S>(parts:Array<Stream<I,Q>>, handler:Handler<I,S>, cb:Conclusion<I,S,Q>->Void) {
        if (parts.length == 0) {
            cb(Depleted);
        }
        else {
            (parts[0]:Stream<I, Q>).forEach( handler ).then(function(o) switch o {
                case Depleted:
                    consumeParts(parts.slice(1), handler, cb);

                case Halted(rest):
                    parts = parts.copy();
                    parts[0] = rest;
                    cb(Halted(new CompoundStream(parts)));

                case Clogged(e, at):
                    if (at.depleted)
                        parts = parts.slice(1);
                    else {
                        parts = parts.copy();
                        parts[0] = at;
                    }
                    cb(Clogged(e, new CompoundStream(parts)));

                case Failed(e):
                    cb(Failed(e));
            });
        }
    }

    override function decompose(into: Array<Stream<I, Q>>) {
        for (s in parts)
            s.decompose( into );
    }

    public static function of<I,Q>(parts: Array<Stream<I, Q>>):CompoundStream<I, Q> {
        var streams:Array<Stream<I, Q>> = new Array();
        for (s in parts)
            s.decompose( streams );
        return new CompoundStream(streams);
    }
}

class CloggedStream<Item> extends StreamBase<Item, Dynamic> {
    var rest: Stream<Item, Dynamic>;
    var error: Dynamic;

    public function new(rest, error) {
        this.rest = rest;
        this.error = error;
    }

    override function next():Next<Step<Item, Dynamic>> {
        return Next.sync(Step.Fail(error));
    }

    override function forEach<S>(handler: Handler<Item, S>):Next<Conclusion<Item, S, Dynamic>> {
        return Next.sync(cast Clogged(error, rest));
    }
}

class BlendStream<Item, Q> extends Generator<Item, Q> {
    /* Constructor Function */
    public function new(a:Stream<Item, Q>, b:Stream<Item, Q>):Void {
        var first = null;
        function wait(s: Stream<Item, Q>) {
            return s.next().map(function(o) {
                if (first == null)
                    first = s;
                return o;
            });
        }

        var n1 = wait( a );
        var n2 = wait( b );

        super(Next.async(function(cb) {
            Promise.either(n1, n2).then(function(o) switch o {
                case Link(item, rest):
                    cb(Link(item, new BlendStream(rest, first == a ? b : a)));

                case End:
                    (first == a ? n2 : n1).then( cb );

                case Fail(e):
                    cb(Fail(e));
            });
        }));
    }
}

class RegroupStream<In, Out, Q> extends CompoundStream<Out, Q> {
    public function new(source:Stream<In, Q>, f:Regrouper<In, Out, Q>, ?prev) {
        if (prev == null) prev = Empty.make();
        var ret = null,
        terminated = false,
        buf = [];

        var next = Stream.flatten(source.forEach(function(item) {
            buf.push(item);
            return f.apply(buf, Flowing).map(function(o):Handled<Dynamic> {
                return switch o {
                    case Converted(v):
                        ret = v;
                        Finish;

                    case Terminated(v):
                        ret = v.or(Empty.make);
                        terminated = true;
                        Finish;

                    case Untouched:
                        Resume;

                    case Errored(e):
                        Clog(e);
                }
            });
        }).map(function(o):Stream<Out, Q> return switch o {
            case Failed(e):
                Stream.ofError(e);

            case Depleted if (buf.length == 0):
                Empty.make();

            case Depleted:
                Stream.flatten(f.apply(buf, Ended).map(function(o) return switch o {
                    case Converted(v): v;
                    case Terminated(v): v.or(Empty.make);
                    case Untouched: Empty.make();
                    case Errored(e): cast Stream.ofError(e);
                }));

            case Halted(_) if (terminated):
                ret;

            case Halted(rest):
                new RegroupStream(rest, f, ret);

            case Clogged(e, rest):
                cast new CloggedStream(e, cast rest);
        }));

        super([prev, next]);
    }
}

enum Conclusion<Item, Safety, Quality> {
    /* the iteration was halted by BackOff() or Finish() */
    Halted(rest: Stream<Item, Quality>):Conclusion<Item, Safety, Quality>;

    /* the iteration was halted by Clog(error) */
    Clogged<Error>(error:Error, at:Stream<Item, Quality>):Conclusion<Item, Error, Quality>;

    /* the stream produced an error */
    Failed<Error>(error:Error):Conclusion<Item, Safety, Error>;

    /* there is no more data left in the stream */
    Depleted():Conclusion<Item, Safety, Quality>;
}

enum Step<Item, Quality> {
    /* reference to the current value in the stream, and the next step */
    Link(v:Item, rest:Stream<Item, Quality>):Step<Item, Quality>;

    /* stream has failed */
    Fail<Error>(error: Error):Step<Item, Error>;

    /* stream has ended; there is no more data */
    End():Step<Item, Quality>;
}

enum Handled<Safety> {
    /* Stop the iteration before the current item */
    BackOff(): Handled<Safety>;

    /* stop the iteration after the current item */
    Finish(): Handled<Safety>;

    /* continue the iteration */
    Resume(): Handled<Safety>;

    /* produce an error */
    Clog<Error>(e: Error): Handled<Error>;
}

enum RegroupStatus<Q> {
    Flowing(): RegroupStatus<Q>;
    Errored<Error>(e: Error): RegroupStatus<Error>;
    Ended(): RegroupStatus<Q>;
}

enum RegroupResult<O, Q> {
    Converted(data: Stream<O, Q>): RegroupResult<O, Q>;
    Terminated(data: Option<Stream<O, Q>>): RegroupResult<O, Q>;
    Untouched(): RegroupResult<O, Q>;
    Errored<Error>(e: Error): RegroupResult<O, Error>;
}

enum ReductionStep<Safety, Result> {
    Progress(result: Result): ReductionStep<Safety, Result>;
    Crash<Error>(e: Error): ReductionStep<Error, Result>;
}

enum Reduction<Item, Safety, Quality, Result> {
    Crashed<Error>(error:Error, at:Stream<Item, Quality>): Reduction<Item, Error, Quality, Result>;
    Failed<Error>(error: Error): Reduction<Item, Safety, Error, Result>;  
    Reduced(result: Result): Reduction<Item, Safety, Quality, Result>;
}

/**
  value used for .reduce actions
 **/
abstract Reducer<Item, Safety, Result> (Result -> Item -> Next<ReductionStep<Safety, Result>>) {
    /* Constructor Function */
    inline function new(f) {
        this = f;
    }

    /**
      apply [this] to something
     **/
    public inline function apply(res:Result, item:Item):Next<ReductionStep<Safety, Result>> {
        return this(res, item);
    }

    /**
      
     **/
    @:from
    public static inline function unknown<Item, Q, Result>(f:Result->Item->Next<ReductionStep<Q, Result>>):Reducer<Item, Q, Result> {
        return new Reducer( f );
    }

    @:from
    public static function unknownSync<Item, Q, Result>(f: Result->Item->ReductionStep<Q, Result>):Reducer<Item, Q, Result> {
        return new Reducer(function(acc:Result, item:Item) {
            return Next.sync(f(acc, item));
        });
    }

    @:from
    public static inline function plainSync<Item, Q, Result>(f: Result->Item->Result):Reducer<Item, Q, Result> {
        return new Reducer(function(acc:Result, item:Item) {
            return Next.sync(Progress(f(acc, item)));
        });
    }

    @:from
    public static inline function plainUnsafeSync<Item, Acc>(f: Acc->Item->Acc):Reducer<Item, Dynamic, Acc> {
        return new Reducer(function(acc:Acc, item:Item) {
            return Next.sync(Progress(f(acc, item)));
        });
    }

    @:from
    public static function plain<Item, Q, Acc>(f: Acc->Item->Next<Acc>):Reducer<Item, Q, Acc> {
        return new Reducer(function(acc:Acc, item:Item) {
            return f(acc, item).derive(function(_, accept, reject) {
                _.future().then(function(result: Result<Acc, Dynamic>) {
                    switch result {
                        case ResSuccess( acc ):
                            accept(Progress( acc ));

                        case ResFailure( err ):
                            accept(Crash( err ));
                    }
                });
            });
        });
    }
}

@:forward
abstract Mapping<I, O, Q> (Regrouper<I, O, Q>) to Regrouper<I, O, Q> {
    inline function new(o) {
        this = o;
    }

    /**
      betty
     **/
    @:from
    public static function plain<In, Out, Q>(f: In->Out):Mapping<In, Out, Q> {
        return new Mapping(Regrouper.syncNoStatus(function(inputs: Array<In>) {
            return Converted(Stream.single(f(inputs[0])));
        }));
    }

    @:from
    public static function sync<In, Out, Error>(f: In->Result<Out, Error>):Mapping<In, Out, Error> {
        return new Mapping(Regrouper.syncNoStatus(function(inputs: Array<In>) {
            return switch f(inputs[0]) {
                case ResSuccess(out): Converted(Stream.single(out));
                case ResFailure(err): Errored(err);
            }
        }));
    }

    @:from
    public static function async<In, Out, Q>(f: In->Next<Out>):Mapping<In, Out, Q> {
        return new Mapping(Regrouper.makeNoStatus(function(inputs: Array<In>) {
            return f(inputs[0]).map(function(o) return Converted(Stream.single(o)));
        }));
    }
}

@:forward
abstract Filter<T, Q> (Regrouper<T, T, Q>) to Regrouper<T, T, Q> {
    /* Constructor Function */
    inline function new(o) {
        this = o;
    }

    @:from
    public static function plain<T, Q>(f: T->Bool):Filter<T, Q> {
        return new Filter(Regrouper.syncNoStatus(function(inputs: Array<T>) {
            return Converted(if (f(inputs[0])) Stream.single(inputs[0]) else Empty.make());
        }));
    }

    @:from
    public static function async<T, Q>(f: T->Next<Bool>):Filter<T, Q> {
        return new Filter(Regrouper.makeNoStatus(function(inputs:Array<T>) {
            return f(inputs[0]).map(function(include) {
                return Converted(include ? Stream.single(inputs[0]) : Empty.make());
            });
        }));
    }
}

@:forward
abstract Regrouper<I,O,Q> (RegrouperBase<I,O,Q>) from RegrouperBase<I,O,Q> to RegrouperBase<I,O,Q> {
    @:from
    public static function make<In, Out, Q>(f: Array<In>->RegroupStatus<Q>->Next<RegroupResult<Out, Q>>):Regrouper<In, Out, Q> {
        return new RegrouperBase( f );
    }

    @:from
    public static function sync<In, Out, Q>(f: Array<In>->RegroupStatus<Q>->RegroupResult<Out, Q>):Regrouper<In, Out, Q> {
        return make(function(i, s) {
            return Next.sync(f(i, s));
        });
    }

    @:from
    public static function makeNoStatus<In, Out, Q>(f: Array<In>->Next<RegroupResult<Out, Q>>):Regrouper<In, Out, Q> {
        return make(function(i, _) return f(i));
    }

    @:from
    public static function syncNoStatus<In, Out, Q>(f: Array<In>->RegroupResult<Out, Q>):Regrouper<In, Out, Q> {
        return sync(function(i, _) return f(i));
    }
}

class RegrouperBase<I, O, Q> {
    /* Constructor Function */
    public function new(f: (i:Array<I>, rs:RegroupStatus<Q>)->Next<RegroupResult<O, Q>>) {
        this.apply = f;
    }

/* === Instance Methods === */

    public dynamic function apply(input:Array<I>, status:RegroupStatus<Q>):Next<RegroupResult<O, Q>> {
        throw 'Not Implemented';
    }
}

abstract Handler<Item, Safety> (Item -> Next<Handled<Safety>>) {
    public inline function new(f: Item -> Next<Handled<Safety>>) {
        this = f;
    }

/* === Methods === */

    public inline function apply(item):Next<Handled<Safety>> {
        return this(item);
    }

/* === Casting Methods === */

    @:from
    public static inline function ofUnknown<Item, Q>(f: Item->Next<Handled<Q>>):Handler<Item, Q> {
        return new Handler( f );
    }

    @:from
    public static inline function ofUnknownSync<Item, Q>(f: Item -> Handled<Q>):Handler<Item, Q> {
        return new Handler(function(item: Item) {
            return Next.sync(f(item));
        });
    }
}

@:forward
abstract Convert<In, Out> (In -> Next<Out>) from In -> Next<Out> to In -> Next<Out> {
    @:from
    public static inline function sync<I, O>(f: I -> O):Convert<I, O> {
        return (function(i) return Next.sync(f(i)));
    }
}

@:forward
abstract Next<T> (Promise<T>) from Promise<T> to Promise<T> {
/* === Methods === */

    public inline function map<O>(f: T->O):Next<O> {
        return this.transform( f );
    }

    public function flatMap<O>(f: T->Next<O>):Next<O> {
        return this.derive(function(root, yes, no) {
            root.then(function(value: T) {
                f(value).then(yes, no);
            }, no);
        });
    }

/* === Casting/Factories === */
    @:from
    public static inline function fromLazy<T>(value: Lazy<T>):Next<T> {
        return new Promise<T>(function(yes, _) {
            yes(value.get());
        });
    }

    @:from
    public static inline function fromAny<T>(value: T):Next<T> {
        return Promise.resolve( value );
    }

    public static inline function sync<T>(value: Lazy<T>):Next<T> return fromLazy( value );
    public static inline function async<T>(f: (T->Void)->Void):Next<T> {
        return new Promise<T>(function(yes, _) {
            f(function(value: T) {
                yes( value );
            });
        });
    }
}
