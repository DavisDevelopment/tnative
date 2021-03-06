package tannus.display.backend.flash;

import tannus.display.backend.flash.*;
import tannus.display.TGraphics;

import tannus.geom.*;
import tannus.graphics.Color;
import tannus.graphics.GraphicsBrush;
import tannus.graphics.GraphicsPath;
import tannus.graphics.PathComponent;
import tannus.graphics.PathStyleAlteration;
import tannus.graphics.LineStyle;
import tannus.graphics.PathStyle;
import tannus.graphics.DrawMode;
import tannus.ds.ActionStack;

import flash.display.Graphics;

class PathRenderer {
	/* Constructor Function */
	public function new(tg : TannusGraphics):Void {
		owner = tg;
		path = null;

		buffer = new ActionStack();
		pathStyle = new PathStyle();
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

			/* == Arc Operation == */
			case Arc( curve ):
				buffer.append({
					drawArc( curve );
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

			/* == Triangle Operation == */
			case Triangle( tri ):
				buffer.append({
					var lines = tri.lines;

					g.moveTo(tri.one.x, tri.one.y);

					for (line in lines) {
						var e = line.end;
						g.lineTo(e.x, e.y);
					}
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
				g.beginFill(0, 0);
				mode = DM_Stroke;
				syncStyles();
				buffer.call();
				g.endFill();


			/* == Fill Operation == */
			case FillPath:
				mode = DM_Fill;
				syncStyles();
				buffer.call();
				g.endFill();

			/* == Clear Operation == */
			case ClearPath:
				buffer = new ActionStack();

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
			case LineBrush( brush ):
				lineStyle.brush = brush;

			/* == Change Fill Color == */
			case FillBrush( brush ):
				pathStyle.fillBrush = brush;

			/* === Change Line Cap === */
			case LineCap( cap ):
				lineStyle.cap = cap;

			/* === Change Line Join === */
			case LineJoin( jon ):
				lineStyle.join = jon;

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
		switch (mode) {
			case DM_Stroke:
				/* == Line Styles == */

				var lcolor:Color = new Color();
				var a:Float = 0;
				lcolor.alpha = 255;

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

				/* === Determine what to do with the current Brush === */
				var brush:GraphicsBrush = lineStyle.brush;
				switch (brush.type) {
					/* Solid Color Brush */
					case BColor( color ):
						a = (255 / color.alpha);
						color.alpha = 0;
						lcolor = color;

						g.lineStyle(lineStyle.width, lcolor, a, false, null, cap, joint);

					/* Linear Gradient Brush */
					case BLinearGradient( grad ):
						var ocolors:Array<Color> = grad.stops.map(function(stop) return (stop.color));
						var ratios:Array<Float> = grad.stops.map(function(stop) return (stop.offset.of(1)));
						var alphas:Array<Float> = ocolors.map(function(color) {
							var a:Float = (255 / color.alpha);
							color.alpha = 0;
							return a;
						});
						var colors:Array<UInt> = ocolors.map(function(c) return cast c.toInt());

						g.lineGradientStyle(LINEAR, colors, alphas, ratios);

					default:
						throw 'Unknown Brush type ${brush.type}!';
				}

			
			case DM_Fill:
				g.lineStyle(1, 0x000000, 0);
				
				switch (pathStyle.fillBrush.type) {
					case BColor( color ):
						var a = (255 / color.alpha);
						color.alpha = 0;

						g.beginFill(color, a);

					case BLinearGradient( grad ):
						var ocolors:Array<Color> = grad.stops.map(function(s) return s.color);
						var ratios:Array<Float> = grad.stops.map(function(s) return s.offset.of(1));
						var alphas:Array<Float> = ocolors.map(function(c) {
							var a:Float = (255 / c.alpha);
							c.alpha = 0;
							return a;
						});
						var colors:Array<UInt> = ocolors.map(function(c) return cast c.toInt());
						g.beginGradientFill(LINEAR, colors, alphas, ratios);
				}
			}

	}

	/**
	  * Reset [this] PathRenderer to it's default state
	  */
	private inline function reset():Void {
		buffer = new ActionStack();
		path = null;
		lineStyle = new LineStyle();
	}

	/**
	  * Draw an Arc
	  */
	private function drawArc(arc:Arc, ?precision:Int = 1):Void {
		var lines:Array<Line> = arc.getLines(precision);

		var first:Line = lines.shift();

		g.moveTo(first.start.x, first.start.y);
		g.lineTo(first.end.x, first.end.y);

		for (line in lines) {
			var p:Point = line.end;

			g.lineTo(p.x, p.y);
		}
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

	/**
	  * Shorthand reference to [pathStyle.lineStyle]
	  */
	public var lineStyle(get, set):LineStyle;
	private inline function get_lineStyle() return pathStyle.lineStyle;
	private inline function set_lineStyle(ns) return (pathStyle.lineStyle = ns);

/* === Instance Fields === */

	//- reference to the TannusGraphics instance which spawned [this]
	private var owner : TannusGraphics;
	
	//- reference to the Path we're currently rendering
	private var path : Null<GraphicsPath>;

	//- Which drawing mode we're currently using
	private var mode : DrawMode;

	//- the current styling for drawn lines
	private var pathStyle : PathStyle;

	//- ActionStack for holding all drawing operations until a 'stroke' or 'fill' is performed
	private var buffer : ActionStack;
}
