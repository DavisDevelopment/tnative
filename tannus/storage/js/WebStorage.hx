package tannus.storage.js;

import tannus.storage.Storage;
import tannus.ds.Object;
import tannus.ds.Delta;

import js.html.Storage in NStorage;

import haxe.Json;
import haxe.Serializer;
import haxe.Unserializer;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
using tannus.ds.MapTools;

class WebStorage extends Storage {
	/* Constructor Function */
	public function new(s:NStorage, pref:String=''):Void {
		super();

		store = s;
		prefix = pref;
	}

/* === Instance Methods === */

	/**
	  * get all keys in [store]
	  */
	private function storeKeys():Array<String> {
		var res = [for (i in 0...store.length) store.key( i )];
		if (prefix != '') {
			res = res.macfilter(_.startsWith( prefix ));
		}
		return res;
	}

	/**
	  * fetch data from [store]
	  */
	override private function _fetch(cb : Data->Void):Void {
		var data:Data = new Data();
		for (key in storeKeys()) {
			data[key.after( prefix )] = decode(store.getItem( key ));
		}
		cb( data );
	}

	/**
	  * push data to [store]
	  */
	override private function _push(data:Data, cb:Err -> Void):Void {
		for (key in data.keys()) {
			var pkey = (prefix + key), val = encode(data[key]);
			store.setItem(pkey, val);
		}
		for (key in deleted) {
			store.removeItem((prefix + key));
		}
		cb( null );
	}

	/**
	  * decode a value
	  */
	private function decode(s : String):Dynamic {
		try {
			return Unserializer.run( s );
		}
		catch (err : Dynamic) {
			return s;
		}
	}

	/**
	  * encode a value
	  */
	private function encode(value : Dynamic):String {
		Serializer.USE_CACHE = true;
		Serializer.USE_ENUM_INDEX = true;
		return Serializer.run( value );
	}

/* === Instance Fields === */

	private var store : NStorage;
	public var prefix : String;
}
