package tannus.graphics;

import tannus.io.Signal;
import tannus.io.Ptr;
import tannus.ds.Maybe;
import tannus.ds.Queue;
import tannus.geom.*;

import tannus.display.TGraphics;

import tannus.graphics.Color;
import tannus.graphics.PathComponent;
import tannus.graphics.PathStyleAlteration;

/**
  * Class to allow the creation and execution of a series a drawing operations, called a "path"
  */
class GraphicsPath {
	/* Constructor Function */
	public function new():Void {
		ops = new Queue();
		graphics = null;
	}

/* === Instance Methods === */

	/**
	  * Push an operation onto the current Stack
	  */
	private inline function add(op : PathComponent):Void {
		stack.push( op );
	}

	/**
	  * Push a Style Alteration onto the current Stack
	  */
	private inline function sc(op : PathStyleAlteration):Void {
		add(StyleAlteration( op ));
	}

	/**
	  * Invoke [f] on every item on the current Stack
	  */
	public inline function each(f : PathComponent->Void):Void {
		for (op in stack) {
			f( op );
		}
	}

	/**
	  * Move the 'cursor' to the given position
	  */
	public function moveTo(pos : Point):Void {
		add(MoveTo(pos));
	}

	/**
	  * Draw a line from the 'cursor', to some other position, moving the cursor as we go
	  */
	public function lineTo(pos : Point):Void {
		add(LineTo(pos));
	}

	/**
	  * Set the current line-thickness
	  */
	public function setLineWidth(width : Float):Void {
		sc(LineWidth( width ));
	}

	/**
	  * Set the current line-color
	  */
	public function setLineColor(color : Color):Void {
		sc(LineColor( color ));
	}

	/**
	  * Strokes [this] Path
	  */
	public function stroke():Void {
		add( StrokePath );
	}

	/**
	  * Draw [this] Path
	  */
	public function draw():Void {
		if (graphics) {
			var g:TGraphics = graphics;
			g.drawPath( this );
		} else {
			throw 'PathError: Cannot draw path; No \'graphics\' field provided!';
		}
	}

/* === Computed Instance Fields === */

	/**
	  * The 'Stack' of Operations currently being operated on
	  */
	public var stack(get, never):Array<PathComponent>;
	private function get_stack():Array<PathComponent> {
		if (!ops.last.exists) {
			ops.append([]);
		}
		return ops.last;
	}

/* === Instance Fields === */

	//- The Queue of States of [this] GraphicsPath
	private var ops : Queue<Array<PathComponent>>;

	//- Optional Pointer to an instance of TGraphics
	public var graphics : Maybe<TGraphics>;
}
