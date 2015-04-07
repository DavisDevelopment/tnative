package tannus.sys;

import tannus.sys.Path;
import tannus.sys.VVType;
import tannus.sys.FileStat;
import tannus.io.Byte;
import tannus.io.ByteArray;

/**
  * Class to represent an entry in a VirtualVolume
  */
class VVEntry {
	/* Constructor Function */
	public function new(vv:VirtualVolume, nam:String, typ:VVType):Void {
		name = nam;
		content = null;
		type = typ;
		meta = new Map();
		volume = vv;

		__init();
	}

/* == Instance Methods === */

	/**
	  * Perform some dope-ass initialization stuff
	  */
	private function __init():Void {
		cdate = Date.now();
	}

	/**
	  * Marks [this] Entry as having been modified just now
	  */
	private inline function update():Void {
		mdate = Date.now();
	}

	/**
	  * List all files which are inside [this] Directory
	  */
	public function list():Array<VVEntry> {
		if (isDirectory) {
			var entries = volume.all();
			return entries.filter(function(e) {
				return (e.path.directory == path);
			});
		} else {
			error('"$path" is a File!');
		}
	}

	/**
	  * Write to [this] File
	  */
	public function write(data : ByteArray):Void {
		if (isFile || !(volume.exists(path))) {
			content = data;
			update();
		} else {
			error('"$path" is a Directory!');
		}
	}

	/**
	  * Reads from [this] File
	  */
	public function read():ByteArray {
		if (isFile) {
			if (content == null) {
				return '';
			} else {
				return content;
			}
		} else {
			error('"$path" cannot be read!');
		}
	}

	/**
	  * Appends [data] to [this] File
	  */
	public function append(data : ByteArray):Void {
		if (isFile) {
			content = read();
			content += data;
			update();
		} else {
			error('"$path" cannot be written to!');
		}
	}

	/**
	  * Renames [this] Entry
	  */
	public function rename(newname : String):Void {
		//- [this] Entry is a File
		if (isFile) {
			name = newname;
		}
		
		//- [this] Entry is a Directory
		else {
			var subs = list();

			for (e in subs) {
				var np:String = e.path.normalize();
				np = StringTools.replace(np, path.normalize(), (new Path(newname).normalize()));
				e.name = np;
			}

			name = newname;
		}
	}

	/**
	  * Returns a serializable representation of [this] Entry
	  */
	public function serialize():Dynamic {
		return {
			'name'    : name,
			'type'    : type,
			'meta'    : meta,
			'content' : content
		};
	}

	/**
	  * Create and return a VVEntry from an Object like that returned by VVEntry's 'serialize' method
	  */
	public static function deserialize(o:Dynamic, vol:VirtualVolume):VVEntry {
		var e:VVEntry = new VVEntry(vol, o.name, (cast o.type));
		e.meta = (cast o.meta);
		e.content = (cast o.content);
		return e;
	}

/* === Computed Instance Fields === */

	/**
	  * 'name' as a Path instance
	  */
	public var path(get, set):Path;
	private inline function get_path():Path {
		return name;
	}
	private inline function set_path(np : Path):Path {
		name = np;
		return name;
	}

	/**
	  * The FileStat for [this] Entry
	  */
	public var stats(get, never):FileStat;
	private function get_stats():FileStat {
		if (isFile) {
			return {
				'size': (read().length),
				'ctime': cdate,
				'mtime': mdate
			};
		} 
		else {
			error('"$path" is a Directory!');
		}
	}

	/**
	  * Whether [this] Entry is a file
	  */
	public var isFile(get, never):Bool;
	private function get_isFile():Bool {
		switch (type) {
			case VVFile: return true;
			default: return false;
		}
	}

	/**
	  * Whether [this] Entry is a directory
	  */
	public var isDirectory(get, never):Bool;
	private inline function get_isDirectory():Bool {
		return !isFile;
	}

	/**
	  * The data-of-creation of [this] Entry
	  */
	public var cdate(get, set):Date;
	private function get_cdate():Date {
		return meta['cdate'];
	}
	private function set_cdate(cd : Date):Date {
		var _cd:Null<Date> = meta['cdate'];
		if (_cd != null && Std.is(_cd, Date)) {
			return _cd;
		}
		else {
			return (meta['cdate'] = cd);
		}
	}

	/**
	  * The last-modified date
	  */
	public var mdate(get, set):Date;
	private function get_mdate():Date {
		var m:Null<Date> = meta['mdate'];
		
		return (m != null ? m : cdate);
	}
	private function set_mdate(nm : Date):Date {
		return (meta['mdate'] = nm);
	}

/* === Instance Fields === */

	public var name:String;
	public var content:Null<ByteArray>;
	public var type:VVType;
	private var meta:Map<String, Dynamic>;
	public var volume:VirtualVolume;

/* === Class Methods === */

	/**
	  * Throws an error with the given message
	  */
	private static inline function error(msg : String):Void {
		throw 'IOError: $msg';
	}
}
