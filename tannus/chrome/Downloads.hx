package tannus.chrome;

import tannus.chrome.Runtime;
import tannus.ds.Object;
import tannus.ds.Maybe;

import tannus.chrome.DownloadOptions;

class Downloads {

	/**
	  * Initiate a new download
	  */
	public static function download(data:DownloadOptions, ?callb:DownloadItem->Void):Void {
		lib.download(data.clone(), function(i : Int) {
			if (callb != null)
				lib.search({'id' : i}, function(dlitems:Array<DownloadItem>) {
					callb(dlitems[0]);
				});
		});
	}

	/**
	  * Observe changes on DownloadItems globally
	  */
	public static function onChange(callb : DownloadDelta->Void):Void {
		lib.onChanged.addListener(function(change:DownloadDelta) {
			callb( change );
		});
	}

	/**
	  * Observe a particular DownloadItem for changes
	  */
	public static function observe(oid:Int, callb:DownloadDelta->Void):Void {
		onChange(function(ch) {
			var id:Int = ch.id;

			if (id == oid) {
				callb( ch );
			}
		});
	}
	
	/**
	  * Reference to the object used internally
	  */
	public static var lib(get, never):Dynamic;
	private static inline function get_lib() return untyped __js__('chrome.downloads');
}

typedef DownloadItem = {
	var id : Int;
	var url : String;
	var referer : String;
	var filename : String;
	var mime : String;
	var bytesReceived : Float;
	var totalBytes : Float;
	var fileSize : Float;
	var exists : Bool;
	var state : DownloadState;
};
