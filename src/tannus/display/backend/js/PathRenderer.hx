package tannus.display.backend.js;

import tannus.display.backend.js.*;

import tannus.graphics.*;
import tannus.geom.Point;

import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;

class PathRenderer {
	/* Constructor Function */
	public function new(graphics : TannusGraphics):Void {
		g = graphics;
	}

/* === Instance Methods === */

	/**
	  * Render the given path
	  */
	public function draw(path : GraphicsPath):Void {
		var ctx:CanvasRenderingContext2D = g.win.ctx;
		var opfunc = performOperation.bind(_, ctx);

		ctx.beginPath();
		path.each( opfunc );
		ctx.closePath();
	}

	/**
	  * Perform a drawing operation
	  */
	public function performOperation(op:PathComponent, c:CanvasRenderingContext2D):Void {
		switch (op) {
			//- Move the 'cursor' to the given position
			case Pc.MoveTo( pos ):
				c.moveTo(pos.x, pos.y);

			//- draw a line from the 'cursor' to the given position
			case Pc.LineTo( pos ):
				c.lineTo(pos.x, pos.y);

			//- stroke the current Path
			case Pc.StrokePath:
				c.stroke();

			//- perform a style alteration
			case Pc.StyleAlteration( change ):
				changeStyle(change, c);

			default:
				throw 'PathError: Unknown Path Operation $op!';
		}
	}

	/**
	  * Perform a Style Alteration
	  */
	public function changeStyle(change:PathStyleAlteration, c:CanvasRenderingContext2D):Void {
		switch (change) {
			//- Change the width of drawn lines
			case Psa.LineWidth( w ):
				c.lineWidth = w;

			//- Change the color of drawn lines
			case Psa.LineColor( color ):
				c.strokeStyle = (color + '');

			default:
				throw 'PathError: Unknown Style Aleration $change!';
		}
	}

/* === Instance Fields === */

	//- reference to the Graphics instance that created [this]
	private var g : TannusGraphics;
}

private typedef Pc = PathComponent;
private typedef Psa = PathStyleAlteration;
