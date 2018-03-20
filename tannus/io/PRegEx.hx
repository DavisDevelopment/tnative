package tannus.io;

import tannus.ds.Thunk;

import tannus.io.RegEx;

import haxe.extern.EitherType as Either;

using StringTools;
using tannus.ds.StringUtils;
using tannus.FunctionTools;

/*
   Procedural Regular Expressions
   --
   heavily inspired by [HaxeVerbalExpression](https://github.com/VerbalExpressions/HaxeVerbalExpressions)
*/
class PRegEx {
    /* Constructor Function */
    public function new():Void {
        _mixins = new Map();
    }

/* === Instance Methods === */

/* === Static Methods === */

    @:native('a')
    public static inline function sanitize(value: String):String {
        return sanitizer.replace(value, "\\$&");
    }

    /**
      * shorthand method to optionally sanitize [value], if [doSanitize] is true
      */
    private inline function sv(value:String, doSanitize:Bool):String {
        return (if (doSanitize) sanitize( value ) else value);
    }

    /**
      * shorthand method to append a "?" (question mark) to the given String
      * if [isNonGreedy] is true
      * (http://docs.activestate.com/activepython/2.5/python/regex/node23.html)
      */
    private inline function gqm(value:String, isNonGreedy:Bool=false):String {
        return optAdd(value, '?', '', isNonGreedy);
    }

    /**
      * get String that denotes the end of a group
      */
    private inline function gend():String return ')';

    /**
      * get the String that denotes the beginning of a group
      */
    private inline function gbegin(?doCapture:Bool, ?groupName:String):String {
        return ('(' + {
            // if not [doCapture]
            if (groupName == null && !(doCapture == null ? false : doCapture))
                '?:';
            else if (groupName != null)
                ('?<' + sanitize( groupName ) + '>');
            else
                '';
        });
    }

    private inline function sor(a:String, b:String):String return (a + '|' + b);
    private static inline function ere(s:String, m:String=''):EReg return new EReg(s, m);

    private inline function optAdd(value:String, a:String, b:String, condition:Bool):String {
        return (value + (if ( condition ) a else b));
    }

    /**
      * return [value] wrapped in [prefix] and [suffix]
      */
    public static function wrap(value:String, prefix:String, ?suffix:String):String {
        if (suffix == null) {
            if (prefix.has("{@}")) {
                var div = prefix.separate("{@}");
                prefix = div.before;
                suffix = div.after;
            }
            else {
                suffix = prefix;
            }
        }
        return (prefix + value + suffix);
    }

    /**
      * optionally 'wrap' [value] based on [condition]
      */
    private static inline function optWrap(value:String, condition:Bool, prefix:String, ?suffix:String):String {
        return (if ( condition ) wrap(value, prefix, suffix) else value);
    }

    /**
      * get the source for the regular expression
      */
    public inline function generate():String {
        return (_prefixes + _source + _suffixes);
    }

    /**
      * get a textual representation of [this]
      */
    public inline function toString():String {
        return ('~/${generate()}/$_modifiers');
    }

    /**
      * convert current expression to an EReg
      */
    public inline function toEReg():EReg {
        return new EReg(generate(), _modifiers);
    }

    /**
      * convert [this] expression to a RegEx
      */
    public inline function toRegEx():RegEx {
        return new RegEx(toEReg());
    }

    /**
      * test if [this] expression matches [str]
      */
    public inline function isMatch(str: String):Bool {
        return (toEReg().match( str ));
    }

    /**
      * compile [this] to a RegEx and pass that RegEx to [action]
      */
    private inline function withre<T>(f: RegEx->T):T {
        return f(toRegEx());
    }

    public inline function replace(s:String, by:String):String {
        return withre(re->re.replace(s, by));
    }

    public inline function split(s: String):Array<String> {
        return withre(re->re.split( s ));
    }

    public inline function matches(s: String):Array<RegExMatch> {
        return withre(re -> re.search( s ));
    }

    public function map(s:String, f:RegExMatch->String):String {
        return withre(function(re: RegEx) {
            return re.mmap(s, f);
        });
    }

    /**
      * create and return a deep-copy of [this]
      */
    public function clone():PRegEx {
        var copy:PRegEx = new PRegEx();
        copy._prefixes = _prefixes;
        copy._source = _source;
        copy._suffixes = _suffixes;
        copy._captures = _captures;
        return copy;
    }

    /**
      * append literal expression to [this]; also refreshes the source expression
      */
    public function add(value:String, doSanitize:Bool=true):PRegEx {
        #if debug
        if (value.empty()) {
            throw 'PRegEx: value cannot be null or empty';
        }
        #end
        _source += sv(value, doSanitize);
        return this;
    }

    /**
      * append a PREVal to [this]
      */
    public function put(value: PREVal):PRegEx {
        return add(value.compile().generate());
    }

    /**
      * append given expression to [this], parsing out and injecting mixins
      */
    private function addmix(value:String, doSanitize:Bool=true):PRegEx {
        var tag:RegEx = new RegEx(ere("\\$(\\w+\\b)", 'g'));
        while (tag.match( value )) {
            add(tag.matchedLeft(), doSanitize);
            if (!_mixins.exists(tag.matched( 1 ))) {
                throw 'PRegEx: Invalid mixin reference "$$${tag.matched(1)}"';
            }
            var mixin:PREVal = _mixins[tag.matched(1)];
            put( mixin );

            value = tag.matchedRight();
        }
        if (value.hasContent()) {
            add(value, doSanitize);
        }
        return this;
    }

    /**
      * mark [this] to start at the first character of the line
      */
    public function startOfLine(enable:Bool=true):PRegEx {
        _prefixes = (enable ? '^' : '');
        return this;
    }

    /**
      * mark [this] to end at the last character of the line
      */
    public function endOfLine(enable:Bool=true):PRegEx {
        _suffixes = (enable ? "$" : '');
        return this;
    }

    public function then(value:String, doCapture:Bool=false, doSanitize:Bool=true):PRegEx {
        return beginGroup( doCapture ).addmix(value, doSanitize).endGroup();
    }

    public function find(value:String, ?doCapture:Bool):PRegEx {
        return then(value, doCapture);
    }

    public function maybe(value:String, doCapture:Bool=false, doSanitize:Bool=true):PRegEx {
        return then(value, doCapture, doSanitize).add('?', false);
    }

    public function anything(greedy:Bool=true, doCapture:Bool=false):PRegEx {
        return then(gqm('.*', !greedy), doCapture, false);
    }

    public function anythingBut(value:String, isGreedy:Bool=true, doCapture:Bool=false, doSanitize:Bool=true):PRegEx {
        return then(gqm('[^{${sv(value, doSanitize)}}]*', !isGreedy), doCapture, false);
    }

    public function something(isGreedy:Bool=true, doCapture:Bool=false):PRegEx {
        return then(gqm('.+', !isGreedy), doCapture, false);
    }

    public function somethingBut(value:String, isGreedy:Bool=true, doCapture:Bool=false, doSanitize:Bool=true):PRegEx {
        return then(gqm('[^{${sv(value, doSanitize)}}]+', !isGreedy), doCapture, false);
    }

    public function lineBreak():PRegEx {
        return add('(?:\n|(?:\r\n))', false);
    }
    public inline function br():PRegEx return lineBreak();

    public function tab():PRegEx return add('\\t');
    public function letter():PRegEx return add('\\w');
    public function word():PRegEx return letter().plus();
    public function digit():PRegEx return add('\\d');
    public function nonDigit():PRegEx return add('\\D');
    public function wordBoundary():PRegEx return add('\\b');
    public function wb():PRegEx return wordBoundary();
    public function nonWhitespace():PRegEx return add('\\S');
    public function whitespace():PRegEx return add('\\s');
    public function backref(n: Int):PRegEx return add('\\$n');
    public function captured(n: Int):PRegEx return backref( n );
    
    public function lookahead(lookFor:PREVal, doSanitize:Bool=false):PRegEx {
        return add('(?=', false).add(lookFor.resolve(), doSanitize).add(')');
    }
    public function before(what:PREVal, doSanitize:Bool=false):PRegEx {
        return lookahead(what, doSanitize);
    }

    public function negLookahead(lookFor:PREVal, doSanitize:Bool=false):PRegEx {
        return add('(?!', false).add(lookFor.resolve(), doSanitize).add(')');
    }
    public function notBefore(what:PREVal, doSanitize:Bool=false):PRegEx return negLookahead(what, doSanitize);

    /**
      * insert a character class
      */
    public function anyOf(value:String, doCapture:Bool=false, doSanitize:Bool=true):PRegEx {
        return add(optWrap('[${sv(value, doSanitize)}]', doCapture, '(', ')'), false);
    }
    public inline function any(value: String):PRegEx return anyOf(value, false, true);

    /**
      * match the last pattern [n] times
      */
    public function count(n: Int):PRegEx {
        return add('{$n}', false);
    }

    /**
      * match the last pattern at least [from] times, and as many as [to] times
      */
    public function countRange(from:Int, to:Int):PRegEx {
        return add('{$from, $to}', false);
    }

    /**
      * match the last pattern at least [n] times
      */
    public function countAtLeast(n: Int):PRegEx {
        return add('{$n,}', false);
    }

    public function notGreedy():PRegEx return add('?', false);

    /**
      * insert character range
      */
    public function range(from1:String, to1:String, ?from2:String, ?to2:String, ?from3:String, ?to3:String, ?from4:String, ?to4:String):PRegEx {
        var v:String = '';
        inline function r(?x:String, ?y:String) {
            if (x != null && y != null)
                v += '$x-$y';
        }
        r(from1, to1);
        r(from2, to2);
        r(from3, to3);
        r(from4, to4);
        return add('[$v]', false);
    }

    /**
      * OR operator
      */
    public function or(?value:PREVal, doSanitize:Bool=true):PRegEx {
        _prefixes += '(';
        _suffixes = (')' + _suffixes);
        _source += ')|(';
        if (value != null)
            return add(value.resolve(), doSanitize);    
        else
            return this;
    }

    /**
      * declare the previous match options using either '*' or '?'
      */
    public function optional(onlyOnce:Bool=true, countNotation:Bool=false):PRegEx {
        return add({
            if ( onlyOnce )
                (countNotation?'{0,1}':'?');
            else
                (countNotation?'{0,}':'*');
        }, false);
    }

    /**
      * match the preceding expression 1 or more times
      */
    public function plus(countNotation:Bool=false):PRegEx {
        return add((countNotation ? '{1,}' : '+'), false);
    }

    /**
      * define a named mixin
      */
    #if python @:native('_def') #end
    public function def(mixinName:String, mixin:PREVal):PRegEx {
        #if debug
        if (ere('\\W').match( mixinName )) {
            throw 'PRegEx: Invalid mixin name. Mixin names may only contain alphanumeric characters';
        }
        #end
        _mixins[mixinName] = mixin;
        return this;
    }

    public function addModifier(modifier:String):PRegEx {
        if (!_modifiers.has( modifier )) {
            _modifiers += modifier;
        }
        return this;
    }

    public function removeModifier(modifier:String):PRegEx {
        _modifiers = _modifiers.remove( modifier );
        return this;
    }

    public function mod(modifier:String, enable:Bool=true):PRegEx {
        return (enable?addModifier:removeModifier)(modifier);
    }

    public function withAnyCase(enable:Bool=true):PRegEx return mod('i', enable);
    public function useOneLineSearchOption(enable:Bool=true):PRegEx return mod('m', enable);

    public function withOptions(options: String):PRegEx {
        _modifiers = options;
        return this;
    }

    /**
      * mark the beginning of a group
      */
    public function beginGroup(capture:Bool=false, ?groupName:String):PRegEx {
        if (groupName != null)
            capture = true;
        if ( capture ) {
            ++_captures;
            if (groupName == null) {
                return add('(', false);
            }
            else {
                return add('(?<', false).add(groupName, true).add('>', false);
            }
        }
        else {
            return add('(?:', false);
        }
    }

    /**
      * mark the end of the last-opened group
      */
    public inline function endGroup():PRegEx {
        return add(')', false);
    }
    public inline function endCapture():PRegEx return endGroup();

    /**
      * build a group
      */
    public function group(body:PREVal, capture:Bool=false, ?groupName:String):PRegEx {
        return beginGroup(capture, groupName).add(build(body).generate()).endGroup();
    }

    public inline function beginCapture(?groupName:String):PRegEx {
        return beginGroup(true, groupName);
    }

    public inline function capture(body:PREVal, ?groupName:String):PRegEx {
        return group(body, true, groupName);
    }

    /**
      * invoke [body] with [this] as its first argument
      * this is intended for more intuitive/readable grouping of build actions
      */
    public inline function exec(body:PRegEx->Void):PRegEx return _( body );
    public function _(body:PRegEx->Void):PRegEx {
        body( this );
        return this;
    }

    /**
      * static method to resolve PREVals
      */
    @:noCompletion
    public static function resolveVal(value: PREVal):String {
        if ((value is String)) {
            return cast value;
        }
        else if ((value is Array<PREValDef>)) {
            return cast(value, Array<Dynamic>).map(x -> resolveVal(cast x)).join('');
        }
        else if (Reflect.isFunction( value )) {
            try {
                var pre = new PRegEx();
                var res:Dynamic = (untyped value)( pre );
                if (res == null) {
                    res = pre;
                }
                return resolveVal(cast res);
            }
            catch (error: Dynamic) {
                var res:Dynamic = (untyped value)();
                if (res == null) {
                    throw 'Error: Functional PREVals must return a non-null value';
                }
                return resolveVal(cast res);
            }
        }
        else {
            return Std.string( value );
        }
    }

    /**
      * functionally build a PRegEx
      */
    public static function build(v: PREVal):PRegEx {
        if ((v is PRegEx)) {
            return cast(v, PRegEx).clone();
        }
        else if ((v is String)) {
            return fromString(cast v);
        }
        else if (Reflect.isFunction( v )) {
            var re = new PRegEx();
            var ret = (untyped v)( re );
            if (ret == null) {
                return re;
            }
            else {
                return build( ret );
            }
        }
        else {
            throw 'PRegEx: Invalid argument to PRegEx.build(...)';
        }
    }

    /**
      * build a new PRegEx from a String
      */
    public static function fromString(s: String):PRegEx {
        if (s.startsWith('~'))
            s = s.after('~');
        if (s.startsWith('/'))
            s = s.after('/');
        var mods:String = s.afterLast('/');
        if (!(~/[^gimu]/.match(mods))) {
            s = s.beforeLast('/');
        }
        if (s.endsWith('/'))
            s = s.beforeLast('/');
        var re:PRegEx = new PRegEx();
        re._source = s;
        re._modifiers = mods;
        return re;
    }

/* === Instance Fields === */

    private var _prefixes:String = "";
    private var _source:String = "";
    private var _suffixes:String = "";
    private var _modifiers:String = "";
    private var _captures:Int = 0;
    private var _mixins:Map<String, PREVal>;

    // regular expression used in "sanitizing" input
    @:native('s')
    private static var sanitizer:EReg = {~/[-\\.,_*+?^$[\](){}!=|]/ig;};
}

typedef PREValDef = Either<Either<PRegEx, String>, Either<Array<PREValDef>, Either<PRegEx->PREValDef, PRegEx->Void>>>;

abstract PREVal (PREValDef) from PREValDef {
    public inline function new(x: PREValDef) {
        this = x;
    }

    @:to
    public inline function resolve():String return PRegEx.resolveVal( this );

    @:to
    public inline function compile():PRegEx return PRegEx.build( this );
}
