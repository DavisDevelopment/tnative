package tannus.storage.js;

import tannus.storage.Storage;
import tannus.ds.Object;
import tannus.ds.Delta;
import tannus.io.Signal;
import tannus.io.ByteArray;
import tannus.html.fs.WebFileEntry;
import tannus.html.fs.WebFile;

import haxe.Json;

using tannus.ds.MapTools;

class WebFileStorage extends Storage {
	/* Constructor Function */
	public function new(_f : WebFileEntry):Void {
		super();

		fe = _f;
		trace( fe );
		f = null;
	}

/* === Instance Methods === */

	/**
	  * get the File
	  */
	private function getFile(cb : WebFile -> Void):Void {
		if (f == null) {
			fe.file().then(function(file) {
				f = file;
				cb( f );
			});
		}
		else {
			cb( f );
		}
	}

	/**
	  * fetch stored data
	  */
	override private function _fetch(cb:Data->Void):Void {
		// get the File
		getFile(function(file) {
			if (file.size == 0) {
				cb(new Data());
			}
			else {
				file.read().then(function(data) {
					if (data == null) {
						data = new ByteArray();
					}
					var odata:Object = Json.parse(data.toString());
					cb( odata );
				});
			}
		});
	}

	/**
	  * clear the meta-file
	  */
	private function clearFile(done : Void->Void):Void {
		var name = (fe.fullPath + fe.name);
		fe.getDirectory().then(function(parent) {
			fe.remove(function() {
				parent.createFile( name ).then(function( _f ) {
					fe = _f;
					f = null;
					done();
				});
			});
		});
	}

	/**
	  * push local data
	  */
	override private function _push(mdata:Data, cb:Err->Void):Void {
		var start = Date.now().getTime();
		clearFile(function() {
			fe.writer().then(function( writer ) {
				var o:Object = mdata.toObject();
				var sdata:String = Json.stringify(o, null, '    ');
				var data:ByteArray = ByteArray.ofString( sdata );
				writer.write(data, function(err) {
					var end = Date.now().getTime();
					var took = (end - start);
					trace('metadata PUSH operation took ${took}ms to complete');
					cb( err );
				});
			});
		});
	}

/* === Instance Fields === */

	private var fe : WebFileEntry;
	private var f : Null<WebFile>;
}
