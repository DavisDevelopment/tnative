package tannus.mvc;

import tannus.storage.Storage;
import tannus.storage.Commit;

import tannus.ds.Async;
import tannus.ds.Delta;
import tannus.ds.Destructible;
import tannus.ds.Memory;
import tannus.ds.Object;
import tannus.io.Ptr;
import tannus.io.EventDispatcher;
import tannus.io.VoidSignal;

import tannus.mvc.Asset;
import tannus.mvc.Requirements;

import haxe.rtti.Meta;

class Model extends EventDispatcher implements Asset {
	/* Constructor Function */
	public function new():Void {
		super();

		assets = new Array();
		readyReqs = new Requirements();
		_ready = new VoidSignal();

		_bindMethodsToEvents();
	}

/* === Instance Methods === */

	/**
	  * Initialize [this] Model
	  */
	public function init(?cb : Void -> Void):Void {
		if (cb != null)
			onready( cb );
		readyReqs.meet(function() {
			sync(function() {
				_ready.fire();
			});
		});
	}

	/**
	  * Wait for [this] Model to be 'ready'
	  */
	public inline function onready(f : Void -> Void):Void {
		_ready.once( f );
	}

	/**
	  * Attach an Asset to [this] Model
	  */
	public inline function link(item : Asset):Void {
		assets.push( item );
	}

	/**
	  * Detach an Asset from [this] Model
	  */
	public inline function unlink(item : Asset):Void {
		assets.remove( item );
	}

	/**
	  * Delete [this] Model entirely
	  -------------------------------
	    would usually refer to the deletion and/or deactivation
	    of the thing the Model represents
	  */
	public function destroy():Void {
		for (a in assets) {
			a.destroy();
		}
	}

	/**
	  * Detach [this] Model
	  ----------------------
	    delete [this] Model instance, NOT the thing 
	    the Model represents
	  */
	public function detach():Void {
		for (a in assets) {
			a.detach();
		}
	}

	/**
	  * require that Task [t] have completed successfully before [this] Model is considered 'ready'
	  */
	private function require(name:String, task:Async):Void {
		readyReqs.add(name, task);
	}

	/**
	  * persist [this] Model's state
	  */
	public function sync(done : Void->Void):Void {
		storage.push( done );
	}
	public function save():Void {
		sync(function() null);
	}

	/**
	  * Get the value of an attribute of [this] Model
	  */
	public function getAttribute<T>(key : String):Null<T> {
		return (storage.get(map_key( key )));
	}
	public inline function get<T>(k : String):Null<T> return getAttribute( k );

	/**
	  * Set the value of an attribute of [this] Model
	  */
	public function setAttribute<T>(key:String, value:T):T {
		return storage.set(map_key(key), value);
	}
	public inline function set<T>(key:String, value:T):T return setAttribute(key, value);

	/**
	  * Get a Pointer to an attribute of [this] Model
	  */
	public function attribute<T>(key : String):Ptr<T> {
		var ref:Ptr<Dynamic> = new Ptr(getAttribute.bind(key), setAttribute.bind(key, _));
		return (untyped ref);
	}

	/**
	  * Check whether [this] Model has an attribute with the given name
	  */
	public function hasAttribute(name : String):Bool {
		return storage.exists(map_key( name ));
	}
	public inline function exists(key : String):Bool return hasAttribute(key);

	/**
	  * Delete the given attribute of [this] Model
	  */
	public function removeAttribute(name : String):Bool {
		var had:Bool = hasAttribute( name );
		storage.remove(map_key( name ));
		return had;
	}
	public inline function remove(key : String):Bool return removeAttribute( key );

	/**
	  * Listen for changes to [this]'s attributes
	  */
	public function watch(cb : Commit -> Void):Void {
		storage.watch( cb );
	}

	/**
	  * Listen for activity on a particular field
	  */
	public function watchKey(key:String, cb:Void -> Void):Void {
		watch(function(com : Commit):Void {
			switch ( com ) {
				case Create(k, _), Delete(k), Change(k, _, _) if (k == key):
					cb();

				default:
					null;
			}
		});
	}

	/**
	  * Modify storage-keys
	  */
	private function map_key(key : String):String {
		return key;
	}

	/**
	  * Perform metadata-based event-binding
	  */
	private function _bindMethodsToEvents():Void {
		var cclass:Class<Model> = Type.getClass( this );
		
		var data:Object = Meta.getFields( cclass );
		for (name in data.keys) {
			var field:Object = data.get(name);
			if (field.exists('handle')) {
				var events:Array<String> = cast field.get('handle');
				var val:Dynamic = Reflect.getProperty(this, name);
				if (!Reflect.isFunction( val ))
					throw 'TypeError: Cannot bind field $name!';

				for (event in events) {
					if (!canDispatch( event )) {
						addSignal( event );
					}

					on(event, untyped val);
				}
			}
		}
	}


/* === Computed Instance Fields === */

	/**
	  * Storage object in use by [this] Model currently
	  */
	public var storage(default, set):Storage;
	private function set_storage(v : Storage):Storage {
		storage = v;

		/* define the 'storage' requirement's Task as the intialization of [storage] */
		readyReqs.add('storage', function(met) {
			v.init( met );
		});

		return storage;
	}

/* === Instance Fields === */

	/* objects 'attached' to [this] Model, to be deleted when [this] is */
	private var assets : Array<Asset>;

	/* signal fired when [storage] becomes usable */
	private var readyReqs : Requirements;

	/* signal fired when [this] Model becomes 'ready' */
	private var _ready : VoidSignal;
}
