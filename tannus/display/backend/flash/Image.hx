package tannus.display.backend.flash;

import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.net.URLRequest;
import flash.events.Event;

import tannus.display.TImage;

class Image implements TImage {
	/* Constructor Function */
	public function new(img : BitmapData):Void {
		image = img;
	}

/* === Computed Instance Fields === */

	/**
	  * The width of the Image
	  */
	public var width(get, never):Int;
	private inline function get_width():Int {
		return (image.width);
	}

	/**
	  * The height of the Image
	  */
	public var height(get, never):Int;
	private inline function get_height():Int {
		return (image.height);
	}

/* === Static Utility Methods === */

	/**
	  * Load an Image from a URL
	  */
	public static function fromURL(_url:String, callb:Image->Void):Void {
		var url:URLRequest = new URLRequest(_url);
		var img:Loader = new Loader();
		img.load( url );

		function loaded(e : Event):Void {
			var bm:Bitmap = cast (new LoaderInfo(e.target).content);
			//var bm:Bitmap = e.target.content;

			var i:Image = new Image(bm.bitmapData);
			callb( i );

			e.target.removeEventListener(Event.COMPLETE, loaded);
		}

		img.contentLoaderInfo.addEventListener(Event.COMPLETE, loaded);
		img.contentLoaderInfo.addEventListener(flash.events.IOErrorEvent.IO_ERROR, function(e : Event) {
			trace('Encountered an IO Error :c');
		});
	}

/* === Instance Fields === */

	/* The Underlying Image */
	public var image : BitmapData;
}
