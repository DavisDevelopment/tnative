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
	public function draw(_path : GraphicsPath):Void {
		path = _path;
		
		if (path.vectorized) {
			path = _path.clone();
			path.devectorize();
		}

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

			//- draw a rectangle
			case Pc.Rectangle( r ):
				c.rect(r.x, r.y, r.w, r.h);

			//- draw an ellipse
			case Pc.Ellipse( r ):
				trace('Ellipse not yet implemented');

			case Pc.SubPath( sub ):
				save();

				sub.draw();
				
				restore();

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

	/**
	  * 'save' the current state of [this] PathRenderer
	  */
	public function save():Void {
		g.win.ctx.save();
	}

	/**
	  * 'restore' [this] PathRenderer to a previous state
	  */
	public function restore():Void {
		g.win.ctx.restore();
	}

/* === Instance Fields === */

	//- reference to the Graphics instance that created [this]
	private var g : TannusGraphics;

	//- reference to the GraphicsPath currently being drawn
	private var path : GraphicsPath;
}

private typedef Pc = PathComponent;
private typedef Psa = PathStyleAlteration;
