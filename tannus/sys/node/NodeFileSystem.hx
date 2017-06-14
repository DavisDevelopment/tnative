package tannus.sys.node;

import tannus.io.ByteArray;
import tannus.io.ByteArray.BinaryImpl;
import tannus.sys.FileStat;

import tannus.node.Buffer;

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
		NFS.writeFileSync(path, data.getData());
	}
	
	public static function read(path:String, ?offset:Int, ?length:Int):ByteArray {
	    if (offset == null && length == null) {
	        var buf = NFS.readFileSync(path);
            return ByteArray.ofData( buf );
        }
        else {
            var id = NFS.openSync(path, 'r+');
            var buff:Buffer = new Buffer( length );
            NFS.readSync(id, buff, 0, length, offset);
            NFS.closeSync( id );
            return ByteArray.ofData( buff );
        }
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

	public static inline function openOutput(path : String):FileOutput {
	    return new tannus.sys.FileOutput(new NodeFileOutput( path ));
	}

	public static inline function openInput(path : String):FileInput {
	    return new tannus.sys.FileInput(new NodeFileInput( path ));
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
