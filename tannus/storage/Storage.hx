package tannus.storage;

import tannus.io.Ptr;
import tannus.io.Signal;

import tannus.ds.Delta;
import tannus.ds.Maybe;
import tannus.ds.Ref;

import tannus.storage.Commit;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.ds.MapTools;

class Storage {
	/* Constructor Function */
	public function new():Void {
		local = new Data();
		remote = null;

		commits = new Array();
		deleted = new Array();
		_ready = false;
		_remote_commit = new Ref( _remoteCommitSignal );
	}

/* === Frontend Instance Methods === */

	/**
	  * Fetch the data from the backend
	  */
	public function fetch(done : Void->Void):Void {
		/* get the backend data */
		_fetch(function(fdata : Data):Void {
			remote = fdata;
			done();
		});
	}

	/**
	  * Push the data to the backend
	  */
	public function push(done : Void->Void):Void {
		/* FETCH the data from the remote */
		_fetch(function(fdata : Data):Void {
			trace('fetched successfully');
			/* apply local commits to the remote data */
			fdata = _applyCommits(fdata, commits);

			/* PUSH the data to the remote */
			_push(fdata, function(err : Err) {
				trace('pushed successfully');
				/* if any errors occurred */
				if (err != null) {
					throw err;
				}

				/* reset [this] Storage's 'local' state */
				local = new Map();
				deleted = new Array();
				commits = new Array();
				
				/* let [this] Storage know about the changes we just made */
				remote = copy( fdata );

				/* we're done now */
				done();
			});
		});
	}

	/**
	  * Initialize [this] Storage
	  */
	public function init(cb : Void->Void):Void {
		/* FETCH, so that we know what the remote looks like */
		fetch(function() {
			_ready = true;

			cb();
		});
	}

	/**
	  * Get the value of the [key] property, if it exists
	  */
	public function get<T>(key : String):Null<T> {
		/* if we have fetched the data from the remote */
		if (remote != null) {
			/* if that property has since been deleted */
			if (deleted.has( key )) {
				return null;
			}

			/*
			   if [key] is a property on the remote, and not locally, return remote[key]
			   if [key] is a property locally, and not remotely, return local[key]
			   if [key] is a local AND remote property, return local[key]
			*/
			var rv = remote.get( key );
			var lv = local.get( key );

			switch ([rv, lv]) {
				/* == exists locally, but not remotely == */
				case [null, loc] if (loc != null):
					return loc;

				/* == exists remotely, but not locally == */
				case [rem, null] if (rem != null):
					return rem;

				/* == exists both locally and remotely == */
				case [rem, loc] if (rem != null && loc != null):
					return loc;

				/* == any other combo == */
				default:
					//trace('WTFCombo: $key => ($rv, $lv)');
					return null;
			}
		}

		else {
			throw 'StorageError: Storage has not been initialized!';
		}
	}

	/**
	  * Set a value
	  */
	public function set<T>(key:String, value:T):T {
		/* if we have fetched the data from the remote */
		if (remote != null) {
			/* if [key] was previously marked as deleted */
			if (deleted.has( key )) {
				/* undo that */
				deleted.remove( key );
				/* commit it's re-creation */
				commit(Create(key, value));
			}
			else {
				// the previous value of [key]
				var prev:Null<Dynamic> = get( key );
				if (prev != null) {
					commit(Change(key, prev, value));
				}
				else {
					commit(Create(key, value));
				}
			}

			local[key] = value;
			
			return value;
		}

		else {
			throw 'StorageError: Storage has not been initialized!';
		}
	}

	/**
	  * Check for existence of a given property
	  */
	public function exists(key : String):Bool {
		if (remote != null) {
			if (deleted.has( key )) {
				return false;
			}
			else {
				return (local.exists(key) || remote.exists(key));
			}
		}
		else {
			throw 'StorageError: Storage has not been initialized!';
		}
	}

	/**
	  * Watch [this] Storage
	  */
	public function watch(handler : Commit->Void):Void {
		var sig = _remote_commit.get();
		sig.on( handler );
	}

	/**
	  * Delete a property
	  */
	public function remove(key : String):Void {
		deleted.push( key );
		commit(Delete( key ));
	}

	/**
	  * Make a reference to the given property
	  */
	public function reference<T>(key : String):Ptr<T> {
		var ref:Ptr<Dynamic> = new Ptr(get.bind(key), set.bind(key, _), remove.bind(key));
		return (untyped ref);
	}

	/**
	  * Get an Array of all keys
	  */
	public function keys():Array<String> {
		return (remote.keyArray().concat(local.keyArray()).unique());
	}

/* === Backend Instance Methods === */

	/**
	  * Backend method for 'fetch'ing data
	  */
	private function _fetch(cb : Data -> Void):Void {
		ni();
	}

	/**
	  * Apply the local Commits to the remote Data
	  */
	private function _applyCommits(rem:Data, coms:Array<Commit>):Data {
		var result:Data = copy( rem );
		for (commit in coms) {
			switch ( commit ) {
				/* == Property Created == */
				case Create(key, value):
					result.set(key, value);

				/* == Property Value Changed == */
				case Change(key, prev, next):
					result.set(key, next);

				/* == Property Deleted == */
				case Delete( key ):
					result.remove( key );
			}
		}
		return result;
	}

	/**
	  * Backend method for 'push'ing data
	  */
	private function _push(data:Data, cb:Err->Void):Void {
		ni();
	}

	/**
	  * Create and return a Signal which fires when Commits are made remotely
	  */
	private function _remoteCommitSignal():Signal<Commit> {
		ni();
		return new Signal();
	}

	/**
	  * Add a Commit to the Stack
	  */
	private inline function commit(c : Commit):Void {
		commits.push( c );
	}

	/**
	  * Create and return a shallow copy of the given Data
	  */
	private static function copy(d : Data):Data {
		var result = new Data();
		for (key in d.keys())
			result.set(key, d.get(key));
		return result;
	}

/* === Computed Instance Fields === */

	/* whether [this] Storage has been initialized */
	public var ready(get, never):Bool;
	private inline function get_ready():Bool return _ready;

/* === Instance Fields === */

	/* the "local" data, which houses any/all "local" changes */
	private var local : Data;

	/* the "remote" data, as it was the last time it was fetched */
	private var remote : Null<Data>;

	/* the list of 'commits' which have been made since the last 'push' */
	private var commits : Array<Commit>;

	/* the list of keys which have been deleted since the last fetch */
	private var deleted : Array<String>;

	/* whether [this] Storage has been initialized */
	private var _ready : Bool;

	/* signal for listening to remote changes */
	private var _remote_commit : Ref<Signal<Commit>>;

/* === Static Methods === */

	/**
	  * raise the 'StorageError: Not Implemented!' exception
	  */
	private static macro function ni() {
		var method = haxe.macro.Context.getLocalMethod();
		var errorType:String = 'StorageError';
		var errorText:String = 'Not Implemented';

		if (method != null) {
			errorType = 'StorageMethodNotImplemented';
			errorText = method;
		}
		
		var error:String = ('$errorType: $errorText!');
		return macro throw $v{error};
	}
}

typedef Data = Map<String, Dynamic>;
typedef Err = Null<Dynamic>;
