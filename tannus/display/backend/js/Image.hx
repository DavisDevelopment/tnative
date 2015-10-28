package tannus.display.backend.js;

import js.html.CanvasElement;
import js.html.ImageElement;
import js.Browser;

import tannus.display.TImage;

class Image implements TImage {
	/* Constructor Function */
	public function new(img : CanvasElement):Void {
		image = img;
	}

/* === Computed Instance Fields === */

	/**
	  * Width of the Image
	  */
	public var width(get, never):Int;
	private inline function get_width():Int {
		return (image.width);
	}
	
	/**
	  * Height of the Image
	  */
	public var height(get, never):Int;
	private inline function get_height():Int {
		return (image.height);
	}

/* === Static Utility Methods === */

	/**
	  * Loads an Image from a URL
	  */
	public static function fromURL(uri:String, callb:Image->Void):Void {
		var doc = Browser.document;
		var iel:ImageElement = doc.createImageElement();
		iel.src = uri;
		iel.onload = function() {
			var canvas:CanvasElement = doc.createCanvasElement();
			canvas.width = iel.width;
			canvas.height = iel.height;

			var c = canvas.getContext('2d');
			c.drawImage(iel, 0, 0, iel.width, iel.height, 0, 0, iel.width, iel.height);

			var img:Image = new Image(canvas);
			callb( img );
		};

		iel.onerror = function() {
			trace('Failed to Load image due to an error :c');
		};
	}

/* === Instance Fields === */

	/* Underlying Native Image */
	public var image : CanvasElement;
}
