package tannus.display.backend.js;

import tannus.display.backend.js.*;

import tannus.graphics.*;
import tannus.geom.*;

import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;

class PathRenderer {
	/* Constructor Function */
	public function new(graphics : TannusGraphics):Void {
		g = graphics;
		style = new PathStyle();
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
				var ell = new Ellipse(r.x, r.y, r.w, r.h);
				var curves = ell.calculateCurves();
				
				for (curv in curves) {
					var s:Point = curv.start;
					c.moveTo(s.x, s.y);
					c.bezierCurveTo( 
						curv.ctrl1.x,
						curv.ctrl1.y,
						curv.ctrl2.x,
						curv.ctrl2.y,
						curv.end.x,
						curv.end.y
					);
				}

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
			case Psa.LineBrush( brush ):
				switch (brush.type) {
					/* Solid Color Brush */
					case BColor( color ):
						c.strokeStyle = (color + '');

					/* Linear Gradient */
					case BLinearGradient( grad ):
						var s:Point = grad.start;
						var e:Point = grad.end;

						var lg = c.createLinearGradient(s.x, s.y, e.x, e.y);
						for (stop in grad.stops) {
							lg.addColorStop((stop.offset.of(1)), (stop.color.toString()));
						}

						c.strokeStyle = lg;

					default:
						var typ:String = Type.getEnumConstructs(tannus.graphics.GraphicsBrushType)[Type.enumIndex(brush.type)];
						throw 'Unknown Brush Type $typ!';
				}

			case Psa.LineCap( cap ):
				switch (cap) {
					case Round:
						c.lineCap = 'round';
					case Square:
						c.lineCap = 'square';
					case Butt:
						c.lineCap = 'butt';
				}

			case Psa.LineJoin( jon ):
				switch (jon) {
					case Bevel:
						c.lineJoin = 'bevel';

					case Miter:
						c.lineJoin = 'miter';

					case Round:
						c.lineJoin = 'round';
				}

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

	//- The current Styling of [this] Path
	private var style : PathStyle;
}

private typedef Pc = PathComponent;
private typedef Psa = PathStyleAlteration;
private typedef Brush = GraphicsBrush;
