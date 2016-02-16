package tannus.storage.js;

import tannus.storage.Storage;
import tannus.ds.Object;
import tannus.ds.Delta;
import tannus.io.Signal;
import tannus.io.VoidSignal;
import tannus.io.ByteArray;
import tannus.html.fs.WebFileEntry;
import tannus.html.fs.WebFile;
import tannus.html.fs.WebFileWriter;

import haxe.Json;

using tannus.ds.MapTools;

class WebFileStorage extends Storage {
	/* Constructor Function */
	public function new(_f : WebFileEntry):Void {
		super();

		fe = _f;
		f = null;
		writer = null;
		_onunlocked = new VoidSignal();
	}

/* === Instance Methods === */

	/**
	  * get the File
	  */
	private function getFile(cb : WebFile -> Void):Void {
		if (f == null) {
			fe.file().then(function( file ) {
				f = file;
				cb( f );
			});
		}
		else {
			cb( f );
		}
	}

	/**
	  * get the Writer
	  */
	private function getWriter(cb : WebFileWriter->Void):Void {
		if (writer == null) {
			fe.writer().then(function(w) {
				writer = w;
				cb( writer );
			});
		}
		else {
			cb( writer );
		}
	}

	/**
	  * fetch stored data
	  */
	override private function _fetch(cb:Data->Void):Void {
		if ( !_locked ) {
			// get the File
			lock();
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
						unlock();
						cb( odata );
					});
				}
			});
		}
		else {
			throw new js.Error( 'Attempted to perform an operation on a Storage while locked!' );
		}
	}

	/**
	  * push local data
	  */
	override private function _push(mdata:Data, cb:Err->Void):Void {
		if ( !_locked ) {
			var start = Date.now().getTime();
			lock();
			getWriter(function( writer ) {
				trace('got writer object');
				var o:Object = mdata.toObject();
				var sdata:String = Json.stringify(o, null, '    ');
				var data:ByteArray = ByteArray.ofString( sdata );
				writer.write(data, function(err : Null<Dynamic>) {
					if (err != null) {
						unlock();
						throw err;
					}
					writer.truncate( writer.position );
					f = null;
					var end = Date.now().getTime();
					var took = (end - start);
					trace('metadata PUSH operation took ${took}ms to complete');
					unlock();
					cb( err );
				});
			});
		}
		else {
			throw new js.Error( 'Attempted to perform an operation on a Storage while locked!' );
		}
	}

	private function lock():Void {
		_locked = true;
	}

	private function unlock():Void {
		_locked = false;
		_onunlocked.fire();
	}

	public inline function isLocked():Bool return _locked;

/* === Instance Fields === */

	private var fe : WebFileEntry;
	private var writer : Null<WebFileWriter>;
	private var f : Null<WebFile>;

	private var _locked : Bool = false;
	private var _onunlocked : VoidSignal;
}
