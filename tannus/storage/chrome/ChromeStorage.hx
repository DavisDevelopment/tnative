package tannus.storage.chrome;

import tannus.storage.Storage;
import tannus.storage.Commit;
import tannus.chrome.StorageArea;
import tannus.chrome.Storage.StorageChange;
import tannus.ds.Object;
import tannus.ds.Delta;
import tannus.io.Signal;

import haxe.Serializer;
import haxe.Unserializer;

using Lambda;
using tannus.ds.MapTools;

class ChromeStorage extends Storage {
	/* Constructor Function */
	public function new(a : StorageArea):Void {
		super();

		area = a;
	}

/* === Instance Methods === */

	/**
	  * Fetch data from [area]
	  */
	override private function _fetch(cb : Data->Void):Void {
		area.get(null, function(data : Object) {
			var d = decode( data );
			cb( d );
		});
	}

	/**
	  * Persist the data to [area]
	  */
	override private function _push(map_data:Data, cb:Err->Void):Void {
		var data:Object = encode( map_data ).toObject();
		area.remove(deleted, function() {
			area.set(data, function() {
				cb( null );
			});
		});
	}

	/**
	  * Watch Signal
	  */
	override private function _remoteCommitSignal():Signal<Commit> {
		/* Signal which we'll fire when changes are made to [area] */
		var signal:Signal<Commit> = new Signal();

		/* when we receive a StorageChange object */
		area.watchAll(function(change : StorageChange):Void {
			var removed:Array<String> = new Array();
			var created:Map<String, Dynamic> = new Map();
			var changed:Map<String, Delta<Dynamic>> = new Map();

			var commits:Array<Commit> = new Array();

			/* translate the StorageChange data into an Array of Commits */
			for (key in change.keys()) {
				var delta = change.get( key );
				switch ([delta.previous, delta.current]) {
					/* == Value Created == */
					case [null, value]:
						created[key] = value;
						commits.push(Create(key, value));

					/* == Value Deleted == */
					case [value, null]:
						removed.push( key );
						commits.push(Delete( key ));

					/* == Value Changed == */
					case [prev, next]:
						changed.set(key, delta);
						commits.push(Change(key, prev, next));
				}
			}

			/* now fire [signal] for every Commit created */
			for (c in commits) {
				signal.call( c );
			}
		});
		return signal;
	}

	/**
	  * encode an Object
	  */
	private function encode(data : Data):Data {
		var e:Data = new Data();
		for (key in data.keys()) {
			e[key] = Serializer.run(data[key]);
		}
		return e;
	}

	/**
	  * decode an Object
	  */
	private function decode(data : Data):Data {
		var d = new Data();
		for (key in data.keys()) {
			d[key] = Unserializer.run( data[key] );
		}
		return d;
	}

/* === Instance Fields === */

	/* the StorageArea being stored to */
	private var area : StorageArea;
}
