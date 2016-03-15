package tannus.storage;

import tannus.ds.Obj;
import tannus.ds.Object;
import tannus.storage.Storage;

import haxe.Serializer;
import haxe.Unserializer;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
using tannus.ds.MapTools;

class SubStorage extends Storage {
	/* Constructor Function */
	public function new(parent : Storage):Void {
		super();

		this.parent = parent;
		key = null;
		prefix = null;
	}

/* === Instance Methods === */

	/**
	  * fetch the remote data
	  */
	override private function _fetch(cb : Data -> Void):Void {
		var dat:Data = new Data();
		parent.fetch(function() {
			if (key != null) {
				var encoded:String = (parent.get( key ) + '');
				var decoded:Object = Unserializer.run( encoded );
				cb(decoded.toMap());
			}
			else if (prefix != null) {
				var keys = parent.keys().macfilter(_.startsWith( prefix ));
				for (key in keys) {
					dat[key.after( prefix )] = parent.get( key );
				}
				cb( dat );
			}
			else {
				throw 'Error: Either key or prefix must be defined, and neither are';
			}
		});
	}

	/**
	  * push local data to remote
	  */
	override private function _push(data:Data, cb:Err->Void):Void {
		if (key != null) {
			var encoded:String = Serializer.run(data.toObject());
			parent.set(key, encoded);
			parent.push(function() {
				cb( null );
			});
		}
		else if (prefix != null) {
			for (key in data.keys()) {
				parent.set((prefix + key), data[key]);
			}
			parent.push(function() {
				cb( null );
			});
		}
		else {
			throw 'Error: Either key or prefix must be defined, and neither are';
		}
	}

	/**
	  * assign a value
	  */
	override public function set<T>(key:String, value:T):T {
		var res = super.set(key, value);
		push(function() null);
		return res;
	}

/* === Instance Fields === */

	private var parent : Storage;
	public var key : Null<String>;
	public var prefix : Null<String>;
}
