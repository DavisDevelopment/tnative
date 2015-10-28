package tannus.sys;

import tannus.io.ByteArray;
import tannus.io.ReadableStream;
import tannus.node.ReadableStream in NStream;
import tannus.node.Buffer in Buf;
import tannus.sys.FileStreamOptions in Fso;

import tannus.sys.FileSystem in Fs;
import tannus.ds.IntRange in Range;

#if node
class FileReadStream extends ReadableStream<ByteArray> {
	/* Constructor Function */
	public function new(p:Path, opts:Fso):Void {
		super();

		path = p;
		o = opts;
	}

/* === Instance Methods === */

	/**
	  * Initialize [this] Stream
	  */
	private function streamSegment():Void {
		/* create a readable stream to the specified File */
		var r:Range = range();
		var opts:Dynamic = {
			'start': r.min,
			'end': r.max
		};
		var rs:Null<NStream> = cast fs.createReadStream(path, opts);

		/* wait for the stream to open */
		rs.on('open', function() {
			/* listen for data on the stream */
			rs.on('data', function(data : Buf) {
				trace('Stream got data');
				if (opened && !closed) {
					write(ByteArray.fromNodeBuffer( data ));
				}
				else {
					throw 'Error: Cannot read from closed or unopened Stream!';
				}
			});

			/* listen for the "close" event */
			rs.on('close', function() {
				trace('Stream closed');
				rs = null;
			});
		});
	}

	/**
	  * Get the normalized range
	  */
	private function range():Range {
		var r:Range = o.range();
		if (r.max == -1) {
			var s = Fs.stat(path);
			r.max = s.size;
		}
		return r;
	}

	/**
	  * open [this] Stream
	  */
	override public function open(?cb : Void->Void):Void {
		super.open(cb);

		streamSegment();
	}

/* === Instance Fields === */

	private var path : Path;
	private var o : Fso;

/* === Static Fields === */

	private static var fs(get, never):Dynamic;
	private static inline function get_fs():Dynamic {
		return (untyped __js__('require'))('fs');
	}
}
#else
typedef FileReadStream = ReadableStream<ByteArray>;
#end
