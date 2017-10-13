package tannus.ds;

import Reflect.*;
import Type.*;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;

class ObjectPath {
    /* Constructor Function */
    public function new(path : String):Void {
        this.path = path;
        this.a = OPLexer.run( path );
        this._slices = null;
    }

/* === Instance Methods === */

    // get the value at [this] path on [c]
    public function get(c : Dynamic):Dynamic { return a.get( c ); }

    // set a value on [c] at [this] path
    public function set(c:Dynamic, v:Dynamic):Dynamic { return a.set(c, v); }

    // delete property referenced by [this] path
    public function remove(c:Dynamic):Bool return a.remove( c );

    public function exists(c:Dynamic):Bool return a.exists( c );

    // get context
    public function context(c:Dynamic, ?descend:OPStep->Dynamic->Dynamic):Dynamic return a.context(c, descend);

    public function split():Array<String> {
        if (_slices == null)
            _slices = OPLexer.split( path );
        return _slices;
    }

    public function slice(pos:Int, ?end:Int):ObjectPath {
        return sjoin(split().slice(pos, end));
    }

    @:noCompletion
    public function _subset(compose : haxe.Constraints.Function):ObjectPath {
        var pieces = (split().copy());
        var _tmp = (untyped compose( pieces ));
        if ((_tmp is Array<String>)) {
            pieces = _tmp;
        }
        return sjoin( pieces );
    }

    public function pop():ObjectPath {
        return _subset(function(s) {
            s.pop();
        });
    }

    public function shift():ObjectPath {
        return _subset(function(s) {
            s.shift();
        });
    }

    public function root():ObjectPath {
        return slice(0, 1);
    }

    public function top():ObjectPath {
        return _subset(function(s : Array<String>) {
            return [s.last()];
        });
    }

    public function plus(other : ObjectPath):ObjectPath {
        return join([this, other]);
    }
    public function plusString(other : String):ObjectPath {
        return plus(new ObjectPath( other ));
    }

    /**
      * convert [this] to a String
      */
    public function toString():String {
        return path;
    }

/* === Computed Instance Fields === */

    public var length(get, never):Int;
    private inline function get_length() return split().length;
    
    public var step(get, never):OPStep;
    private inline function get_step() return a;

/* === Instance Fields === */

    // textual representation of [this] ObjectPath
    public var path : String;

    // the individual pieces of [path]
    private var _slices : Null<Array<String>>;

    // object-model of parsed path
    private var a : OPStep;

/* === Static Methods === */

    public static function sjoin(pieces : Array<String>):ObjectPath {
        return new ObjectPath(pieces.join( '.' ));
    }

    public static function join(paths : Array<ObjectPath>):ObjectPath {
        var chunks:Array<String> = new Array(), result = new Array();
        for (op in paths) {
            chunks = chunks.concat(op.split());
        }
        for (chunk in chunks) {
            if (OPLexer.SELFS.has( chunk )) {
                continue;
            }
            else if (OPLexer.SUPERS.has( chunk )) {
                if (result.empty()) {
                    result.push('@super');
                }
                else {
                    result.pop();
                }
            }
            else {
                result.push( chunk );
            }
        }
        return sjoin( result );
    }
}

class OPLexer {
    /* Constructor Function */
    public function new() {
        _step = null;
        buf = '';
    }

/* === Instance Methods === */

    /**
      *
      */
    public function lexString(s : String):Null<OPStep> {
        buf = s;
        _step = null;
        _consumeLex();
        return _step;
    }

    /**
      * parse out all individual pieces of given ObjectPath
      */
    public function splitString(s : String):Array<String> {
        buf = s;
        _step = null;
        _slices = new Array();
        _consumeSplit();
        return _slices;
    }

    /**
      * consume and tokenize the entire buffer
      */
    private function _consumeLex():Void {
        var key:String = '', escaped:Bool = false;
        var index:Int = 0;
        while (index < buf.length) {
        //for (index in 0...buf.length) {
            var c = buf.charAt(index);
            if (STEPCHARS.has( c )) {
                if (key.empty() && STEPCHARS.has(buf.charAt(index + 1))) {
                    index += 2;
                    step('@super');
                    continue;
                }

                step( key );
                key = '';
            }
            else {
                key += c;
            }

            ++index;
        }
        if (key.length > 0) {
            step(key);
        }
    }

    private function _consumeSplit():Void {
        var piece:String = '', escaped:Bool = false;
        var index = 0;
        //for (index in 0...buf.length) {
        while (index < buf.length) {
            var c = buf.charAt( index );
            if (STEPCHARS.has( c )) {
                // next char is '.' as well
                if (piece.empty() && STEPCHARS.has(buf.charAt(index + 1))) {
                    index += 2;
                    slice( '@super' );
                    continue;
                }
                if ( escaped ) {
                    escaped = false;
                }
                else {
                    if (!piece.empty()) {
                        slice( piece );
                        piece = '';
                    }
                }
            }
            else if (c == '\\') {
                escaped = true;
            }
            else {
                if ( escaped ) {
                    escaped = false;
                }
                piece += c;
            }

            ++index;
        }
        if (!piece.empty()) {
            slice( piece );
        }
    }

    /**
      * add a path slice to context
      */
    private function slice(s : String):Void {
        _slices.push( s );
    }

    /**
      * add a step to the context
      */
    private function step(k : String):Void {
        var prev = _step;
        _step = {
            name: k,
            source: prev
        };
    }
/* === Instance Fields === */

    private var _step : Null<OPStep>;
    private var _slices : Null<Array<String>>;
    private var buf : String;

    public static inline var STEPCHARS:String = './';
    public static var SUPERS:Array<String> = {['..', '@super', '@^'];};
    public static var SELFS:Array<String> = {['@this', '@-', '&'];};

/* === Static Methods === */

    public static inline function run(s:String):Null<OPStep> {
        return new OPLexer().lexString(s);
    }

    public static inline function split(s : String):Array<String> {
        return new OPLexer().splitString( s );
    }

    public static function join(pieces : Array<String>):OPStep {
        return run(pieces.join('.'));
    }
}

@:structInit
class OPStep {
    public var name : String;
    @:optional
        public var source : OPStep;

    /**
      * get value
      */
    public inline function get(ctx : Dynamic):Dynamic {
        return getProperty((source!=null?source.get(ctx):ctx), name);
    }

    /**
      * assign value
      */
    public function set(c:Dynamic, v:Dynamic):Dynamic {
        setProperty((source!=null?source.defaultGet(c,{}):c), name, v);
        return get( c );
    }

    /**
      * delete property referenced by [this]
      */
    public function remove(c : Dynamic):Bool {
        return deleteField(context( c ), name);
    }

    public function exists(c : Dynamic):Bool {
        return hasField(context( c ), name);
    }

    /**
      * obtain reference to the Object that [this] OPStep will actually be manipulating
      */
    public function context(ctx:Dynamic, ?descend:OPStep->Dynamic->Dynamic):Dynamic {
        if (descend == null) {
            descend = (function(step, ctx) {
                return step.get( ctx );
            });
        }
        return (source != null ? descend(source, ctx) : ctx);
    }

    /**
      * 
      */
    public function root(ctx : Dynamic):Dynamic {
        return getRootStep().get( ctx );
    }
    public function firstChild(ctx : Dynamic):Dynamic {
        return getFirstNonRoot().ternary(_.get( ctx ), null);
    }

    /**
      * get value, or if value not found, default value
      */
    public function defaultGet(c:Dynamic, dv:Dynamic):Dynamic {
        var res = get(c);
        if (res == null) {
            return set(c, dv);
        }
        else return res;
    }

    /**
      * get the top-most key
      */
    public inline function getRootKey():String {
        return (getRootStep().name);
    }
    public inline function getFirstNonRootKey():Maybe<String> {
        return (getFirstNonRoot().ternary(_.name, null));
    }

    /**
      * get the root (top-most) OPStep
      */
    public function getRootStep():OPStep {
        var v:OPStep = this;
        while (v.source != null)
            v = v.source;
        return v;
    }

    public function getFirstNonRoot():Maybe<OPStep> {
        var v:Array<OPStep> = [this, null];
        while (v[0].source != null) {
            var _tmp = v[0];
            v[1] = _tmp;
            v[0] = _tmp.source;
        }
        return v[1];
    }

    public function isSuperReference():Bool return OPLexer.SUPERS.has( name );
    public function isSelfReference():Bool return OPLexer.SELFS.has( name );
    public function isSpecial():Bool return (isSuperReference() || isSelfReference());
}
