package tannus.storage;

import tannus.io.Signal;
import tannus.ds.Obj;
import tannus.ds.Object;
import tannus.storage.Storage;
import tannus.storage.Commit;
import tannus.io.Getter;

import haxe.Serializer;
import haxe.Unserializer;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
using tannus.ds.MapTools;

class SubStorage extends Storage {
	/* Constructor Function */
	public function new(paref : Getter<Storage>):Void {
		super();

		_parent = paref;
		key = null;
		prefix = null;
		autoPush = true;
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
			for (key in deleted) {
				parent.remove(globalKey( key ));
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
	  * watch for commits
	  */
	override private function _remoteCommitSignal():Signal<Commit> {
		var sig = new Signal();
		parent.watch(function(commit) {
			switch ( commit ) {
				case Commit.Change(key, prev, next):
					if (relevantKey( key )) {
						sig.call(Change(localKey(key), prev, next));
					}

				case Create(key, value):
					if (relevantKey( key )) {
						sig.call(Create(localKey( key ), value));
					}

				case Delete( key ):
					if (relevantKey( key )) {
						sig.call(Delete(localKey( key )));
					}
			}
		});
		return sig;
	}

	private function relevantKey(k : String):Bool {
		if (key != null) {
			return (k == key);
		}
		else if (prefix != null) {
			return (k.startsWith( prefix ));
		}
		else {
			return false;
		}
	}

	private inline function localKey(k : String):String {
		if (prefix != null) {
			return k.after( prefix );
		}
		else {
			return k;
		}
	}

	private inline function globalKey(k : String):String {
		if (prefix != null) {
			return (prefix + k);
		}
		else {
			return k;
		}
	}

	/**
	  * assign a value
	  */
	override public function set<T>(key:String, value:T):T {
		var res = super.set(key, value);
		if ( autoPush ) {
			push(function() null);
		}
		return res;
	}

/* === Computed Instance Fields === */

	private var parent(get, never):Storage;
	private inline function get_parent():Storage return _parent.get();

/* === Instance Fields === */

	public var key : Null<String>;
	public var prefix : Null<String>;
	public var autoPush : Bool;

	private var _parent : Getter<Storage>;
}
