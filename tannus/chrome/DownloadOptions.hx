package tannus.chrome;

import tannus.ds.Object;

using StringTools;
abstract DownloadOptions (Object) from Dynamic {
	public inline function new(d : Dynamic) {
		this = new Object(d);
	}

/* === Instance Methods === */

	public inline function clone():DownloadOptions {
		return new DownloadOptions({
			'url' : url,
		        'filename' : filename,
			'saveAs' : saveAs,
		       	'conflictAction' : (this['conflictAction'] || 'prompt')
		});
	}

/* === Instance Fields === */

	/* URL to Download */
	public var url(get, set):String;
	private inline function get_url() return (this['url'].orDie('DownloadOptions.url cannot be null!'));
	private inline function set_url(nurl:String) return (this['url'] = nurl);

	/* Filename given to File upon completion of the Download */
	public var filename(get, set):Null<String>;
	private inline function get_filename() return (this['filename'] || null);
	private inline function set_filename(nfn:String) return (this['filename'] = nfn);

	/* SaveAs */
	public var saveAs(get, set):Bool;
	private inline function get_saveAs() return (this['saveAs'].or( true ));
	private inline function set_saveAs(n:Bool) return (this['saveAs'] = n);
}

typedef DownloadDelta = {
    id: Int,
    ?url: Delta<String>,
    ?finalUrl: Delta<String>,
    ?filename: Delta<String>,
    ?startTime: Delta<String>,
    ?endTime: Delta<String>,
    ?mime: Delta<String>,
    ?state: Delta<DownloadState>,
    ?paused: Delta<Bool>,
    ?error: Delta<String>,
    ?totalBytes: Delta<Float>,
    ?fileSize: Delta<Float>,
    ?exists: Delta<Bool>
};

/*
typedef DownloadDelta = {
	var id : Int;
	@:optional var url : Delta<String>;
	@:optional var mime : Delta<String>;
	@:optional var state : Delta<DownloadState>;
};
*/

typedef Delta<T> = {
	?previous:T,
	?current:T
};

@:enum
abstract DownloadState (String) from String to String {
	var InProgress = 'in_progress';
	var Complete = 'complete';
	var Interrupted = 'interrupted';
}
