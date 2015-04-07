package tannus.sys;

import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.io.Ptr;
import tannus.sys.Path;
import tannus.sys.VVEntry;
import tannus.sys.VVType;
import tannus.sys.FileStat;

import haxe.Serializer;
import haxe.Unserializer;

/**
  * Class which acts as a virtual filesystem
  */
class VirtualVolume {
	/* Constructor Function */
	public function new(nam : String):Void {
		name = nam;
		entries = new Array();
	}

/* === Instance Methods == */

	/**
	  * Get the Array of all entries in [this] VirtualVolume
	  */
	public inline function all():Array<VVEntry> {
		return entries;
	}

	/**
	  * Retrieves an entry by name
	  */
	public function getEntry(name : String):Null<VVEntry> {
		name = normal(name);
		for (f in entries) {
			if (f.path == name) {
				return f;
			}
		}
		return null;
	}

	/**
	  * Creates a new Entry and adds it to [this] Volume
	  */
	private inline function create(name:String, type:VVType):VVEntry {
		name = normal(name);
		var e = new VVEntry(this, name, type);
		entries.push( e );
		return e;
	}

	/**
	  * Takes a Path, and validates that it's valid
	  */
	private function validatePath(p : Path):Void {
		name = normal(name);
		var _p:Path = p;
		while (true) {
			if (_p.root) {
				break;
			}
			else {
				_p = (_p.directory);
				
				if (!exists(_p)) {
					error('No such file or directory "$_p"!');
				}
			}
		}
	}

	/**
	  * Checks whether there is any entry named [name]
	  */
	public function exists(name : String):Bool {
		name = normal(name);
		var p:Path = name;
		return (getEntry(p) != null);
	}

	/**
	  * Checks whether an entry is a Directory
	  */
	public function isDirectory(name : String):Bool {
		name = normal(name);
		var e = getEntry(name);
		if (e == null) {
			return false;
		} else {
			switch (e.type) {
				case VVFolder:
					return true;

				default:
					return false;
			}
		}
	}

	/**
	  * Creates a new Directory
	  */
	public function createDirectory(name : String):Void {
		name = normal(name);
		validatePath( name );
		create(name, VVFolder);
	}

	/**
	  * Deletes a Directory
	  */
	public function deleteDirectory(name : String):Void {
		name = normal(name);
		if (isDirectory(name)) {
			var e = getEntry(name);
			var subs = e.list();
			if (subs.length == 0) {
				entries.remove( e );
			} else {
				error('Directory not empty "$name"!');
			}
		}
	}

	/**
	  * Retrieve an Array of all children of the given directory
	  */
	public function readDirectory(name : String):Array<String> {
		name = normal(name);
		if (isDirectory(name)) {
			var e = getEntry(name);
			return e.list().map(function(e) return e.name);
		} else {
			error('"$name" is not a Directory!');
		}
	}

	/**
	  * Writes to a File
	  */
	public function write(path:String, data:ByteArray):Void {
		path = normal(path);
		validatePath(path);
		
		var e = getEntry(path);
		if (e == null) {
			e = create(path, VVFile);
		}

		e.write( data );
	}

	/**
	  * Reads from a file
	  */
	public function read(path : String):ByteArray {
		path = normal(path);
		var e = getEntry(path);

		if (e != null && e.isFile) {
			return e.read();
		} else {
			error('"$path" is either a Directory, or does not exist!');
		}
	}

	/**
	  * Append to a File
	  */
	public function append(path:String, data:ByteArray):Void {
		path = normal(path);
		var e = getEntry(path);

		if (e != null && e.isFile) {
			e.append( data );
		}
		else {
			error('"$path" cannot be written to!');
		}
	}

	/**
	  * Deletes a given File
	  */
	public function deleteFile(path : String):Void {
		path = normal(path);
		var e = getEntry(path);

		if (e != null && e.isFile) {
			entries.remove( e );
		}
		else {
			error('Cannot delete "$path"!');
		}
	}

	/**
	  * Renames an entry
	  */
	public function rename(oldp:String, newp:String):Void {
		oldp = normal(oldp);
		newp = normal(newp);

		if (exists(oldp)) {
			validatePath( newp );

			var e = getEntry(oldp);
			e.rename(newp);
		} 
		else {
			error('No such file or directory "$oldp"!');
		}
	}

	/**
	  * Gets the stats on a File
	  */
	public function stat(path : String):FileStat {
		path = normal(path);
		var e = getEntry(path);

		if (e != null) {
			return e.stats;
		}
		else {
			error('No such file or directory "$path"!');
		}
	}

	/**
	  * Serializes [this] VirtualVolume
	  */
	public function serialize():ByteArray {
		var bits:Array<Dynamic> = new Array();

		for (e in entries) {
			bits.push(e.serialize());
		}

		var data:ByteArray = new ByteArray();

		Serializer.USE_CACHE = true;
		Serializer.USE_ENUM_INDEX = true;
		data.write(Serializer.run( bits ));
		
		return data;
	}


/* === Instance Fields === */

	public var name:String;
	private var entries:Array<VVEntry>;

/* === Class Methods === */

	/**
	  * Deserializes a VirtualVolume, and returns it
	  */
	public static function deserialize(data : ByteArray):VirtualVolume {
		var bits:Array<Dynamic> = Unserializer.run( data );
		var vv:VirtualVolume = new VirtualVolume('wut');

		for (bit in bits) {
			var e = VVEntry.deserialize(bit, vv);
			vv.entries.push( e );
		}

		return vv;
	}

	/**
	  * Throws an error with the given message
	  */
	private static inline function error(msg : String):Void {
		throw 'IOError: $msg';
	}

	/**
	  * Does stuff
	  */
	private static inline function normal(name : String):String {
		return (new Path(name).normalize());
	}
}
