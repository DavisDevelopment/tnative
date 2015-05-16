package tannus.graphics;

import tannus.graphics.Color;
import tannus.geom.Point;
import tannus.io.Ptr;
import tannus.io.Getter;
import tannus.io.ByteArray;
import tannus.ds.Maybe;
import tannus.sys.File;

import haxe.io.Bytes;

import format.png.Reader;
import format.png.Tools;

/**
  * Class to Represent a Bitmap Image
  */
class Image {
	/* Constructor Function */
	public function new(w:Int, h:Int, ?pixls:ByteArray):Void {
		_w = w;
		_h = h;

		if (pixls != null) {
			trace('Pixel Data Provided');
			_data = pixls;
		}
		else {
			trace('Generating New Pixel Data');
			_data = new ByteArray();

			for (i in 0...(w*h)) {

				_data += [0, 255, 255, 255];
			}
		}
	}

/* === Instance Methods === */
	


/* === Static Methods === */

	/**
	  * Load an Image instance from a File
	  */
	public static function fromFile(f : File):Image {
		var inp = f.input;

		/* Get the Data from the Image */
		var dat = (new Reader(inp).read());

		/* Get the Pixel Data */
		var _b = Tools.extract32(dat);
		Tools.reverseBytes(_b);

		/* Get the Header Data */
		var hed = Tools.getHeader(dat);
		
		return new Image(hed.width, hed.height, _b);
	}

/* === Computed Instance Fields === */

	/* width of [this] Image */
	public var width(get, never):Int;
	private inline function get_width() return _w;

	/* height of [this] Image */
	public var height(get, never):Int;
	private inline function get_height() return _h;

/* === Instance Fields === */

	/* Internal Width of [this] Image */
	private var _w:Int;
	
	/* Internal Height of [this] Image */
	private var _h:Int;

	/* Internal PixelData for [this] Image */
	private var _data:ByteArray;
}
