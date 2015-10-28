package tannus.display.backend.java;

import java.net.URL;
import java.javax.imageio.ImageIO;
import java.awt.image.BufferedImage;

import tannus.display.TImage;

class Image implements TImage {
	/* Constructor Function */
	public function new(img : JImg):Void {
		image = cast(img, BufferedImage);
	}

/* === Computed Instance Fields === */

	/**
	  * The width of the Image
	  */
	public var width(get, never):Int;
	private inline function get_width():Int {
		return (image.getWidth());
	}
	
	/**
	  * The height of the Image
	  */
	public var height(get, never):Int;
	private inline function get_height():Int {
		return (image.getHeight());
	}

/* === Static Utility Methods === */

	/**
	  * Load an Image from a URL
	  */
	public static function fromURL(_url:String, callb:Image->Void):Void {
		var url:URL = new URL(_url);
		var img:JImg = ImageIO.read( url );
		var image:Image = new Image( img );

		callb( image );
	}

/* === Instance Fields === */

	/* Underlying Native Image */
	public var image : BufferedImage;
}

/* Alias for the native implementation */
private typedef JImg = java.awt.Image;
