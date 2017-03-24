package tannus.sys;

import haxe.io.Path in P;

import tannus.io.ByteArray;
import tannus.sys.Mimes;
import tannus.sys.Mime;

using StringTools;
using Lambda;
using tannus.ds.StringUtils;
using tannus.ds.ArrayTools;

@:access( haxe.io.Path )
class CPath {
	/* Constructor Function */
	public function new(str : String):Void {
		s = str;
	}

/* === Instance Methods === */

    public inline function plusPath(other : Path):Path {
        return join([this, other]);
    }
    public inline function plusString(other : String):Path {
        return plusPath(new Path( other ));
    }

	/* convert [this] Path to a String */
	public inline function toString():String {
		return s;
	}

	/* normalize [this] Path */
	public function normalize():Path {
		var norm:String = s;
		//norm = norm.split('\\').join(separator).replace((separator+separator), separator);
        norm = ssplit( norm ).join( separator );
		var _root = norm.startsWith( separator );
		if ( _root )
			norm = norm.after(separator);
		var r = new Path( norm );
		if ( absolute ) {
			r = r.absolutize();
		}
		return r;
	}

	/* make [this] Path absolute */
	public function absolutize():Path {
		var spath:String = (toString() + '');
		if (isWindows()) {
            if (drive == null || drive == '') {
                spath = ('C:\\' + spath);
            }
        }
        else {
            if (!spath.startsWith( separator )) {
                spath = (separator + spath);
            }
        }
        return new Path( spath );
	}

	/* expand [this] Path */
	public function expand():Path {
		var pieces:Array<String> = this.pieces;
		var res:Array<String> = new Array();
		for (n in pieces) {
			switch ( n ) {
				case '.', '':
					null;

				case '..':
					res.pop();

				default:
					res.push( n );
			}
		}
		var p:Path = new Path(res.join('/'));
		if ( absolute ) p = p.absolutize();
		return p;
	}

	/**
	 * obtain a Path which is [other] relative to [this]
	 */
	public function resolve(other : Path):Path {
		var res:Path = join([this, other]).expand();
		if ( absolute ) {
			res = res.absolutize();
		}
		return res;
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

			return sjoin( respieces );
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

    public var drive(get, never):Null<String>;
    private inline function get_drive():Null<String> {
        return (s.has(':')?s.before(':'):null);
    }

	/* the parent-directory of [this] Path */
	public var directory(get, set):Path;
	private function get_directory():Path {
		return new Path( sdir );
	}
	private function set_directory(v : Path):Path {
		s = sjoin([v.toString(), name]).toString();
		if (v.absolute && !s.startsWith(separator)) {
			s = (separator + s);
		}
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
		return (s.split(separator));
	}
	private function set_pieces(v : Array<String>):Array<String> {
		s = sjoin( v ).toString();
		return pieces;
	}

/* === Instance Fields === */

	private var s : String;

/* === Static Methods === */

	/* join the given array into a Path */
	public static function join(list : Array<Path>):Path {
		var bits:Array<String> = new Array();
		var resroot = (list[0] != null && list[0].absolute);

		for (path in list) {
			bits = bits.concat( path.pieces );
		}
		bits = bits.filter(function(s) return (s != null && !s.empty()));

		var sum:Path = new Path(bits.join(separator)).normalize();
		if ( resroot ) {
			sum = sum.absolutize();
		}
		return sum;
	}

	/* join the given Strings */
	public static function sjoin(list : Array<String>):Path {
	    var isabsolute:Bool = (list.length > 0 && P.isAbsolute(list[0]));
	    var bits:Array<String> = new Array();
	    for (s in list) {
	        bits = bits.concat(ssplit( s ));
	    }
	    var result:Path = new Path(bits.join( separator )).normalize();
	    if ( isabsolute ) {
	        result = result.absolutize();
	    }
	    return result;
	}

	/**
	  * perform manual split
	  */
	public static function ssplit(s : String):Array<String> {
		// either kind of path separator
		var seps = ['/', '\\'];
		var bits:Array<String> = new Array();
		var bit:String = '';
		var i:Int = 0;
		while (i < s.length) {
			var c = s.byteAt( i );
			if (c.equalsChar('/') || c.equalsChar('\\')) {
				if (bit.length > 0) {
					bits.push( bit );
					bit = '';
				}
			}
			else {
				bit += s.charAt( i );
			}
			i++;
		}
		if (bit.length > 0) {
			bits.push( bit );
		}
		return bits;
	}

	public static inline function split(p : Path):Array<String> {
		return ssplit( p.s );
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

		var result:CPath = sjoin( pieces ).normalize();

		return result;
	}

	/* raise a PathError */
	private static inline function err(msg : String):Void {
		throw 'PathError: $msg';
	}

    /* check whether we're running in Windows */
    public static inline function isWindows():Bool {
        return (tannus.TSys.systemName() == 'Windows');
    }

/* === Static Fields === */

    /* platform-specific path separator */
    private static var separator(get, never):String;
    private static function get_separator():String {
        if (_sep == null) {
            _sep = (isWindows() ? '\\' : '/');
        }
        return _sep;
    }

    private static var _sep:Null<String>=null;
}
