package tannus.chrome;

import tannus.ds.Object;
import tannus.chrome.WindowType;

@:forward
abstract WindowData (CWindowData) {
	/* Constructor Function */
	public inline function new(o : Object):Void {
		this = new CWindowData(o);
	}

	
	/**
	  * Implicitly cast from Dynamic
	  */
	@:from
	public static inline function fromDynamic(d : Dynamic) return new WindowData(d);

	@:from
	public static inline function fromObject(o : Object) return new WindowData(o);
}

class CWindowData {
	/* Constructor Function */
	public function new(o : Object):Void {
		url = new Array();
		
		var _url = o['url'];
		if (_url) {
			if (Std.is(_url, Array)) {
				url = url.concat(cast(_url, Array<Dynamic>).map(Std.string.bind(_)));
			} else if (Std.is(_url, String)) {
				url.push(_url + '');
			}
		}

		focused = (o['focused'] || o['active'] || true);
		incognito = (o['incognito'] || false);
		type = (o['type'] || Normal);
		left = (o['left'] || 0);
		top = (o['top'] || 0);
		
		if (o['width'].exists)
			width = (o['width']);
		if (o['height'].exists)
			height = (o['height']);
	}

/* === Instance Fields === */

	public var url:Array<String>;

	public var focused:Bool;

	public var incognito:Bool;

	public var type:WindowType;

	public var left:Int;
	public var top:Int;
	public var width:Int;
	public var height:Int;
}
