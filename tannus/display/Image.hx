package tannus.display;

import tannus.display.TImage;

@:forward
abstract Image (TImage) {
	public inline function new(img : TImage):Void {
		this = img;
	}

/* === Static Utility Methods === */

	/**
	  * Load an Image from a URL
	  */
	public static inline function fromURL(url:String, onload:Image->Void):Void {
		var lf = (function(s:String, f:TImage->Void) null);

		#if java
			lf = tannus.display.backend.java.Image.fromURL.bind(_, _);
		#elseif flash
			lf = tannus.display.backend.flash.Image.fromURL.bind(_, _);
		#elseif js
			lf = tannus.display.backend.js.Image.fromURL.bind(_, _);
		#else
			throw 'Cheeks';
		#end

		lf(url, function(img : TImage) {
			
			onload(new Image(img));
		});
	}
}
