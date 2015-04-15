package tannus.display.backend.flash;

import tannus.display.backend.flash.*;
import tannus.display.TGraphics;

import tannus.geom.*;
import tannus.graphics.Color;
import tannus.graphics.GraphicsPath;
import tannus.graphics.PathComponent;
import tannus.graphics.PathStyleAlteration;
import tannus.graphics.LineStyle;
import tannus.ds.ActionStack;

import flash.display.Graphics;

class PathRenderer {
	/* Constructor Function */
	public function new(tg : TannusGraphics):Void {
		owner = tg;
		path = null;
		buffer = new ActionStack();
		lineStyle = new LineStyle();
	}

/* === Instance Methods === */

	/**
	  * Draw a GraphicsPath
	  */
	public function draw(_path : GraphicsPath):Void {
		reset();
		path = _path;

		if (path.vectorized) {
			path = path.clone();
			path.devectorize();
		}

		var drawn:Bool = false;
		buffer.append(drawn = true);

		path.each(drawComponent.bind(_));

		if (!drawn) {
			buffer.call();
		}
	}

	/**
	  * Perform a drawing operation
	  */
	private function drawComponent(op : PathComponent):Void {
		//trace('Drawing $op');
		switch ( op ) {
			/* == MoveTo Operation == */
			case MoveTo( pos ):
				buffer.append({
					g.moveTo(pos.x, pos.y);
				});

			/* == LineTo Operation == */
			case LineTo( pos ):
				buffer.append({
					g.lineTo(pos.x, pos.y);
				});

			/* == Rectangle Operation == */
			case Rectangle( r ):
				buffer.append({
					g.moveTo(r.x, r.y);
					g.drawRect(r.x, r.y, r.w, r.h);
				});

			/* == Ellipse Operation == */
			case Ellipse( r ):
				buffer.append({
					g.moveTo(r.x, r.y);
					g.drawEllipse(r.x, r.y, r.w, r.h);
				});

			/* == StyleAlteration Operation == */
			case StyleAlteration( change ):
				buffer.append({
					changeStyle(change);
				});

			/* == SubPath Operation == */
			case SubPath( sub ):
				buffer.append({
					sub.draw();
				});

			/* == Stroke Operation == */
			case StrokePath:
				g.beginFill(0x000000, 0);
				syncStyles();
				buffer.call();
				g.endFill();

			/* == Everything Else == */
			default:
				throw 'PathError: Cannot draw $op!';
		}
	}

	/**
	  * Perform a style-alteration operation
	  */
	private function changeStyle(change : PathStyleAlteration):Void {
		switch ( change ) {
			/* == Change Line Width == */
			case LineWidth( nwidth ):
				lineStyle.width = nwidth;

			/* == Change Line Color == */
			case LineColor( color ):
				lineStyle.color = color;

			/* == Anything Else == */
			default:
				throw 'PathError: Cannot perform style alteration $change!';
		}

		syncStyles();
	}

	/**
	  * Style [g] to match the styles of [path]
	  */
	private function syncStyles():Void {
		/* == Line Styles == */

		var lcolor:Color = lineStyle.color.clone();
		var a:Float = (255 / lcolor.alpha);
		lcolor.alpha = 0;

		//- determine cap-style
		var cap:flash.display.CapsStyle = (switch (lineStyle.cap) {
			case Butt  : NONE;
			case Round : ROUND;
			case Square: SQUARE;
		});

		var joint:flash.display.JointStyle = (switch (lineStyle.join) {
			case Bevel : BEVEL;
			case Miter : MITER;
			case Round : ROUND;
		});

		// g.lineStyle(thickness, color, alpha, null, null, capStyle, jointStyle);
		g.lineStyle(lineStyle.width, lcolor, a, false, null, cap, joint);
	}

	/**
	  * Reset [this] PathRenderer to it's default state
	  */
	private inline function reset():Void {
		buffer = new ActionStack();
		path = null;
		lineStyle = new LineStyle();
	}

/* === Computed Instance Fields === */

	/**
	  * Reference to the Window object
	  */
	private var win(get, never):Window;
	private inline function get_win() {
		return (owner.win);
	}

	/**
	  * Reference to the Window object's 'graphics' field
	  */
	private var g(get, never):Graphics;
	private inline function get_g() {
		return (win.canvas.graphics);
	}

/* === Instance Fields === */

	//- reference to the TannusGraphics instance which spawned [this]
	private var owner : TannusGraphics;
	
	//- reference to the Path we're currently rendering
	private var path : Null<GraphicsPath>;

	//- the current styling for drawn lines
	private var lineStyle : LineStyle;

	//- ActionStack for holding all drawing operations until a 'stroke' or 'fill' is performed
	private var buffer : ActionStack;
}
