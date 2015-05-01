package tannus.display;

#if flash
import flash.display.Sprite;
import flash.display.Graphics;
#end

#if (js && !node)
import js.html.CanvasElement;
#end

import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.io.Ptr;
import tannus.display.RenderingSystem;
import tannus.display.Window;

/**
  * Class meant to unify the various rendering systems
  */
class RenderingContext {
	/* Constructor Function */
	public function new(_w : Window):Void {
		win = _w;
	}

/* === Instance Methods === */

	/**
	  * Draw a Rectangle
	  */
	public function drawRect(x:Float, y:Float, w:Float, h:Float):Void {
		switch (win.renderer) {
			case Flash(sprite):
				var g:Graphics = sprite.graphics;
				g.draw
		}
	}

/* === Instance Fields === */

	//- reference to the Window instance
	private var win:Window;
}

#if flash

typedef CanvasElement = Dynamic;
typedef CanvasContext = Dynamic;

#elseif (js && !node)

typedef CanvasContext = js.html.CanvasRenderingContext2d;
typedef Sprite = Dynamic;
typedef Graphics = Dynamic;

#end
