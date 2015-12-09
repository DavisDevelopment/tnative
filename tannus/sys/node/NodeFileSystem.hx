package tannus.sys.node;

import tannus.io.ByteArray;
<<<<<<< HEAD
import tannus.io.ByteArray.BinaryImpl;
=======
import tannus.node.WritableStream;
import tannus.io.streams.NodeOutputStream;
import tannus.io.OutputStream;
>>>>>>> b5c059df8d1f39d87ad27136cf47e923c02cbdfe
import tannus.sys.FileStat;

#if (js && node)
class NodeFileSystem {
	public static inline function exists(path : String):Bool {
		return NFS.existsSync(path);
	}

	public static function isDirectory(path : String):Bool {
		var stats = NFS.statSync(path);
		return stats.isDirectory();
	}

	public static inline function createDirectory(path : String):Void {
		NFS.mkdirSync(path);
	}

	public static inline function deleteDirectory(path : String):Void {
		NFS.rmdirSync(path);
	}

	public static inline function readDirectory(path:String, recursive:Bool=false):Array<String> {
		return NFS.readdirSync(path);
	}

	public static function write(path:String, data:ByteArray):Void {
		NFS.writeFileSync(path, cast(data, tannus.io.impl.JavaScriptBinary).toBuffer());
	}
	
	public static function read(path:String, ?length:Int):ByteArray {
		var buf = NFS.readFileSync(path);
		return BinaryImpl.fromBuffer( buf );
	}

	public static function copy(src:Path, dest:Path, cb:Null<Dynamic>->Void):Void {
		var cbCalled:Bool = false;
		function done(?err : Dynamic):Void {
			if (!cbCalled) {
				cbCalled = true;
				cb( err );
			}
		}
		
		var rd = NFS.createReadStream(src, {});
		rd.on('error', untyped done.bind(_));

		var wr = NFS.createWriteStream(dest, {});
		wr.on('error', untyped done.bind(_));

		wr.on('close', function() {
			done();
		});
		rd.pipe( wr );
	}

	public static function append(path:String, data:ByteArray):Void {
		var c:ByteArray = read(path);
		c = c.concat( data );
		write(path, c);
	}

<<<<<<< HEAD
=======
	/* create a readable stream from a File */
	public static function istream(path:String, opts:Fso):FileReadStream {
		return new FileReadStream(path, opts);
	}

	/* create a writable stream to a File */
	public static function ostream(path : String):OutputStream {
		// create a new fs.WritableStream to [path]
		var node_wstream:WritableStream = NFS.createWriteStream( path );
		// wrap it in a tannus.io.streams.NodeOutputStream object
		var nos:NodeOutputStream = new NodeOutputStream( node_wstream );
		// wrap that in a tannus.io.OutputStream object
		var out:OutputStream = new OutputStream( nos );
		// return that
		return out;
	}

>>>>>>> b5c059df8d1f39d87ad27136cf47e923c02cbdfe
	public static function deleteFile(path : String):Void {
		NFS.unlinkSync(path);
	}

	public static inline function rename(o:String, n:String):Void {
		NFS.renameSync(o, n);
	}

	public static function stat(path : String):FileStat {
		var s = NFS.statSync(path);
		
		return {
			'size': s.size,
			'mtime': fromJSDate(s.mtime),
			'ctime': fromJSDate(s.ctime)
		};
	}

/* === Private utility methods === */

	/**
	  * Convert a String date to an actual date object
	  */
	private static function dateFromString(s : String):Date {
		var bits:Array<String> = s.split('T');
		var dat:String = bits[0];
		var tim:String = bits[1];
		tim = StringTools.replace(tim, 'Z', '');

		bits = dat.split('-');
		var year:Int = Std.parseInt(bits[0]);
		var month:Int = Std.parseInt(bits[1]);
		var day:Int = Std.parseInt(bits[2]);

		bits = tim.split(':');
		var hour:Int = Std.parseInt(bits[0]);
		var minute:Int = Std.parseInt(bits[1]);
		var second:Int = Std.parseInt(bits[2]);

		return new Date(year, month, day, hour, minute, second);
	}

	/**
	  * Converts a JS Date to a Haxe Date
	  */
	private static function fromJSDate(s : Dynamic):Date {
		var year:Int = s.getFullYear();
		var month:Int = s.getMonth();
		var day:Int = s.getDate();
		var hour:Int = s.getHours();
		var minute:Int = s.getMinutes();
		var second:Int = s.getSeconds();
		
		return new Date(year, month, day, hour, minute, second);
	}
}

private typedef NFS = tannus.sys.node.NodeFSModule;
#end
