package tannus.sys;

import haxe.io.Path in P;

import tannus.io.ByteArray;
import tannus.sys.Mimes;
import tannus.sys.Mime;

using StringTools;
using Lambda;
using tannus.ds.StringUtils;
using tannus.ds.ArrayTools;

@:forward
@:access( haxe.io.Path )
abstract Path (CPath) from CPath to CPath {
    /* Constructor Function */
    public inline function new(s : String):Void {
        this = new CPath( s );
    }
    
/* === Operator Overloads === */

    /* get the sum of two Paths */
    @:op(A + B)
    public static inline function sum(x:Path, y:Path):Path {
        return new Path(CPath.join([x.toString(), y.toString()]));
    }
    
/* === Implicit Casting Methods === */

    /* to String */
    @:to
    public inline function toString():String {
        return this.toString();
    }
    
    /* from String */
    @:from
    public static inline function fromString(s : String):Path {
        return new Path( s );
    }
    
    /* to ByteArray */
    @:to
    public inline function toByteArray():ByteArray {
    	return ByteArray.ofString(toString());
    }
    
    /* from ByteArray */
    @:from
    public static inline function fromByteArray(b : ByteArray):Path {
    	return fromString(b.toString());
    }
}

@:access( haxe.io.Path )
private class CPath {
    /* Constructor Function */
    public function new(str : String):Void {
        s = str;
    }
    
/* === Instance Methods === */

    /* convert [this] Path to a String */
    public inline function toString():String {
        return s;
    }
    
    /* normalize [this] Path */
    public function normalize():Path {
        return P.normalize(toString());
    }
    
    /* make [this] Path absolute */
    public function absolutize():Path {
        var spath:String = (toString() + '');
        if (!spath.startsWith('/'))
            spath = ('/' + spath);
        return new Path( spath );
    }
    
    /* expand [this] Path */
    public inline function expand():Path {
        return _expand( this );
    }
    
    /**
      * obtain a Path which is [other] relative to [this]
      */
    public function resolve(other : Path):Path {
        if ( !absolute ) {
            err('Cannot resolve a relative Path by another relative Path; One of them must be absolute!');
        }
        else {
            // the sum of [this] and [other]
            var joined:CPath = join([toString(), other.toString()]).normalize();
            
            // [joined], with all expansions resolved
            var result:Path = joined.expand();
            
            return result;
        }
        
        //- placeholder return, so the compiler doesn't complain
        return new Path('');
    }
    
    /* create a relative Path from [this] to [other] */
    public function relative(other : Path):Path {
        if (absolute && other.absolute) {
            var a:Array<String> = pieces;
            var b:Array<String> = other.pieces;
            // pieces to keep
            var keep:Array<String> = new Array();
            // number of pieces to delete
            var diffs:Int = 0;
            // pieces to add
            var additions:Array<String> = new Array();
            var diffhit:Bool = false;
            
            for (i in 0...a.length) {
                var mine:String = a[i];
                var yurs:Null<String> = b[i];
                if (mine != yurs) {
                    diffhit = true;
                }
                
                if ( !diffhit ) {
                    keep.push( mine );
                }
                else {
                    diffs++;
                    if (yurs != null) {
                        additions.push( yurs );
                    }
                }
            }
            
            var respieces:Array<String> = (['..'].times(diffs).concat(additions));
            
            return join( respieces );
        }
        else {
            err('Both Paths must be absolute!');
        }
        return '';
    }
    
/* === Computed Instance Fields === */

    /* the parent-directory of [this] Path */
    public var sdir(get, never):String;
    private function get_sdir():String {
        return P.directory(s);
    }
    
    /* [this] Path, as a String */
    public var str(get, set):String;
    private function get_str():String {
        return s;
    }
    private function set_str(v : String):String {
        return (s = v);
    }
    
    /* the parent-directory of [this] Path */
    public var directory(get, set):Path;
    private function get_directory():Path {
        return new Path( sdir );
    }
    private function set_directory(v : Path):Path {
        s = join([v.toString(), name]).toString();
        return directory;
    }
    
    /* the name of [this] Path */
    public var name(get, set):String;
    private function get_name():String {
        return P.withoutDirectory(s);
    }
    private function set_name(v : String):String {
        s = join([sdir, v]).toString();
        return name;
    }
    
    /* the basename of [this] Path */
    public var basename(get, set):String;
    private function get_basename():String {
        return P.withoutExtension(s);
    }
    private function set_basename(v : String):String {
        name = (v + '.$extension');
        return basename;
    }
    
    /* the extension-name of [this] Path */
    public var extension(get, set):String;
    private function get_extension():String {
        return P.extension(s);
    }
    private function set_extension(v : String):String {
        s = (s.beforeLast('.') + '.$v');
        return extension;
    }
    
    /* the Mime-Type (based on [extension]) of [this] Path */
    public var mime(get, never):Null<Mime>;
    private function get_mime():Null<Mime> {
    	if (!extension.empty()) {
	    	return new Mime(Mimes.getMimeType(extension));
    	}
    	else {
    		return null;
    	}
    }
    
    /* whether [this] is the root directory */
    public var root(get, never):Bool;
    private function get_root():Bool {
        return (sdir.empty());
    }
    
    /* whether [this] Path is absolute */
    public var absolute(get, never):Bool;
    private function get_absolute():Bool {
        return P.isAbsolute( s );
    }
    
    /* all of the segments of [this] Path */
    public var pieces(get, set):Array<String>;
    private function get_pieces():Array<String> {
        return (s.split('/'));
    }
    private function set_pieces(v : Array<String>):Array<String> {
        s = join( v ).toString();
        return pieces;
    }
    
/* === Instance Fields === */

    private var s : String;
    
/* === Static Methods === */

    /* join the given array into a Path */
    public static function join(list : Array<String>):Path {
        var res:String = P.join( list );
        
        return new Path( res );
    }
    
    /* interpret/resolve any expansions in the given Path */
    public static function _expand(p : CPath):CPath {
        var segments = p.pieces;
        var pieces = new Array();
        
        for (s in segments) {
            switch ( s ) {
                case '.', '':
                    continue;
                    
                case '..':
                    pieces.pop();
                    
                default:
                    pieces.push( s );
            }
        }
        
        var result:CPath = join( pieces ).normalize();
        
        return result;
    }
    
    /* raise a PathError */
    private static inline function err(msg : String):Void {
        throw 'PathError: $msg';
    }
}
