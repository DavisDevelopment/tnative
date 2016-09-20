package tannus.mvc;

import tannus.storage.Storage;
import tannus.storage.Commit;

import tannus.ds.Async;
import tannus.ds.Delta;
import tannus.ds.Destructible;
import tannus.ds.Memory;
import tannus.ds.Object;
import tannus.ds.Maybe;
import tannus.io.Ptr;
import tannus.io.Signal;
import tannus.io.EventDispatcher;
import tannus.io.VoidSignal;

import tannus.mvc.Asset;
import tannus.mvc.Requirements;

import haxe.rtti.Meta;

using tannus.ds.ArrayTools;

class Model extends EventDispatcher implements Asset {
	/* Constructor Function */
	public function new():Void {
		super();

		am = new ModelCollection( this );
		change = new Signal();
		assets = new Array();
		readyReqs = new Requirements();
		_isready = false;
		_ready = new VoidSignal();
		_ready.once(function() {
			_isready = true;
		});
		_a = new Map();

		_bindMethodsToEvents();

		var saving : Bool = false;
		change.on(function( c ) {
			if (autoSave && !saving) {
				saving = true;
				sync(function() saving = false);
			}
		});
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
		done();
	}


	public function save():Void {
		sync(function() null);
	}

	/**
	  * Watch for changes
	  */
	public function watch<T>(f : ModelChange<T> -> Void):Void {
		change.on( f );
	}
	public function unwatch<T>(?f : ModelChange<T> -> Void):Void {
		if (f == null) change.clear();
		else {
			change.off( f );
		}
	}

	/**
	  * Watch a given key for changes
	  */
	public function watchKey(key:String, f:Void->Void):Void {
		change.on(function(c) {
			if (c.name == key) {
				f();
			}
		});
	}

	/**
	  * Get the value of an attribute of [this] Model
	  */
	public function getAttribute<T>(key : String):Null<T> {
		return untyped _a.get( key );//(storage.get(map_key( key )));
	}
	public inline function get<T>(k : String):Null<T> return getAttribute( k );
	public inline function mget<T>(k : String):Maybe<T> return get( k );

	/**
	  * Set the value of an attribute of [this] Model
	  */
	public function setAttribute<T>(key:String, value:T):T {
		var d = {name:key, value:new Delta(value, get(key))};
		_a.set(key, value);//storage.set(map_key(key), value);
		var curr = _a.get( key );
		change.call( d );
		return untyped curr;
	}
	public inline function set<T>(key:String, value:T):T return setAttribute(key, value);

	/**
	  * Get a Pointer to an attribute of [this] Model
	  */
	public function reference<T>(key : String):Ptr<T> {
		var ref:Ptr<Dynamic> = new Ptr(getAttribute.bind(key), setAttribute.bind(key, _));
		return (untyped ref);
	}

	/**
	  * Get an Attribute object for an attribute of [this] Model
	  */
	public function attribute<T>(key:String, ?dv:Void->T):Attribute<T> {
		var a:Attribute<T> = (untyped new Attribute(this, key));
		if (dv != null)
			a.defaultValue = dv;
		return bindAttribute( a );
	}

	public function listAttribute<T>(key:String, ?dv:Void -> Array<T>):ListAttribute<T> {
		var a:ListAttribute<T> = (untyped new ListAttribute(this, key));
		if (dv != null)
			untyped a.defaultValue = dv;
		return bindAttribute( a );
	}

	/**
	  * Bind the given Attribute to [this] Model
	  */
	public function bindAttribute<T:Attribute<Dynamic>>(a : T):T {
		if (a.model != this)
			a.rebind( this );
		am.addAttribute( a );
		return a;
	}

	/**
	  * Check whether [this] Model has an attribute with the given name
	  */
	public function hasAttribute(name : String):Bool {
		return untyped _a.exists( name );//storage.exists(map_key( name ));
	}
	public inline function exists(key : String):Bool return hasAttribute(key);

	/**
	  * Delete the given attribute of [this] Model
	  */
	public function removeAttribute(name : String):Bool {
		return _a.remove( name );
	}
	public inline function remove(key : String):Bool return removeAttribute( key );

	/**
	  * Get an Array of the names of all attributes
	  */
	public function allAttributes():Array<String> {
		return [for (k in _a.keys()) k];
	}
	public inline function keys():Array<String> return allAttributes();

	/**
	  * Erase all data stored in [this] Model
	  */
	public function clearAttributes():Void {
		keys().each(remove( _ ));
		save();
	}
	public inline function clear():Void clearAttributes();

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
	  * whether [this] Model is currently ready to be used
	  */
	public var isReady(get, never):Bool;
	private inline function get_isReady():Bool return _isready;

	/**
	  * Storage object in use by [this] Model currently
	  */
	/*
	public var storage(default, set):Storage;
	private function set_storage(v : Storage):Storage {
		storage = v;

		// define the 'storage' requirement's Task as the intialization of [storage]
		readyReqs.add('storage', function(met) {
			v.init( met );
		});

		return storage;
	}
	*/

/* === Instance Fields === */

	/* whether to sync [this] Model automagically */
	public var autoSave : Bool = false;

	/* the Attribute manager for [this] Model */
	@:allow( tannus.mvc.Attribute )
	private var am : ModelCollection;

	/* objects 'attached' to [this] Model, to be deleted when [this] is */
	private var assets : Array<Asset>;

	/* signal fired when [storage] becomes usable */
	public var readyReqs : Requirements;
	
	/* a Signal fired when changes are made to [this] Model */
	public var change : Signal<ModelChange<Dynamic>>;

	/* signal fired when [this] Model becomes 'ready' */
	private var _ready : VoidSignal;
	private var _isready : Bool;

	/* a Map to store attribute values in */
	private var _a : Map<String, Dynamic>;
//	private var _watchers : Null<Array<ModelChange<Dynamic> -> Void>> = null;
}

typedef ModelChange<T> = {
	var name : String;
	var value : Delta<T>;
};
