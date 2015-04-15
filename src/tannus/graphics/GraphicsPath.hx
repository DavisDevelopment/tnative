package tannus.graphics;

import tannus.io.Signal;
import tannus.io.Ptr;
import tannus.ds.Maybe;
import tannus.ds.Queue;
import tannus.geom.*;
import tannus.math.Percent;

import tannus.display.TGraphics;

import tannus.graphics.Color;
import tannus.graphics.LineStyle;
import tannus.graphics.PathComponent;
import tannus.graphics.PathStyleAlteration;

/**
  * Class to allow the creation and execution of a series a drawing operations, called a "path"
  */
class GraphicsPath {
	/* Constructor Function */
	public function new(?paren:GraphicsPath):Void {
		ops = new Queue();
		graphics = null;
		_vectorized = false;

		parent = paren;
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
	  * Move the 'cursor' to the given position (expressed as a Point)
	  */
	public function move(pos : Point):Void {
		add(MoveTo(pos));
	}

	/**
	  * Move the 'cursor' to the given position
	  */
	public function moveTo(x:Float, y:Float):Void {
		add(MoveTo([x, y]));
	}

	/**
	  * Draw a line from the 'cursor', to some other position (expressed as a Point), moving the cursor as we go
	  */
	public function line(pos : Point):Void {
		add(LineTo(pos));
	}

	/**
	  * Draw a line from the 'cursor', to some other position, moving the cursor as we go
	  */
	public function lineTo(x:Float, y:Float):Void {
		add(LineTo([x, y]));
	}

	/**
	  * Draw a Rectangle
	  */
	public function rectangle(rect : Rectangle):Void {
		add(Rectangle( rect ));
	}

	/**
	  * Draw an Ellipse
	  */
	public function ellipse(rect : Rectangle):Void {
		add(Ellipse( rect ));
	}

	/**
	  * Open and return a sub-path
	  */
	public function open():GraphicsPath {
		var sub:GraphicsPath = new GraphicsPath( this );
		sub.graphics = graphics;

		return sub;
	}

	/**
	  * Close [this] Path
	  */
	public function close():Void {
		if (nested) {
			parent.add(SubPath( this ));
		}
		else {
			#if debug
				throw 'PathError: Cannot close root GraphicsPath!';
			#end
			null;
		}
	}

	/**
	  * Strokes [this] Path
	  */
	public function stroke():Void {
		add( StrokePath );
	}

	/**
	  * Fills [this] Path
	  */
	public function fill():Void {
		add( FillPath );
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

/* === Styling Fields/Methods === */

	/**
	  * Line Width
	  */
	public var lineWidth(get, set):Float;
	private function get_lineWidth():Float {
		var lw:Null<Float> = null;

		for (op in stack) {
			switch (op) {
				case StyleAlteration(LineWidth( w )):
					lw = w;

				default:
					continue;
			}
		}

		return (lw != null ? lw : LineStyle.DEFAULT_WIDTH);
	}
	private function set_lineWidth(nw : Float):Float {
		setLineWidth( nw );
		return nw;
	}

	/**
	  * Line Color
	  */
	public var lineBrush(get, set):Color;
	private function get_lineBrush():Color {
		var lb:Maybe<Color> = null;

		for (op in stack) {
			switch (op) {
				case StyleAlteration(LineColor( ncol )):
					lb = ncol;

				default:
					continue;
			}
		}

		return lb.or(LineStyle.DEFAULT_COLOR);
	}
	private function set_lineBrush(nb : Color):Color {
		setLineColor( nb );
		return nb;
	}

	/**
	  * Set the current line-thickness
	  */
	private inline function setLineWidth(width : Float):Void {
		sc(LineWidth( width ));
	}

	/**
	  * Set the current line-color
	  */
	private inline function setLineColor(color : Color):Void {
		sc(LineColor( color ));
	}



/* === Utility Methods === */

	/**
	  * Clone [this] Path
	  */
	public function clone():GraphicsPath {
		//- create new GraphicsPath instance
		var copy:GraphicsPath = new GraphicsPath();
		//- set [copy]'s "graphics" field to [graphics]
		copy.graphics = graphics;
		
		//- create a new Array, which will become [copy]'s "stack" field
		var cstack:Array<PathComponent> = new Array();
		
		//- iterate over all of [this] Path's operations
		for (op in stack) {
			//- and push copies of them onto [cstack]
			switch (op) {
				//- MoveTo Operation
				case MoveTo(pos):
					cstack.push(MoveTo(pos.clone()));

				//- LineTo Operation
				case LineTo(pos):
					cstack.push(LineTo(pos.clone()));

				//- Rectangle Operation
				case Rectangle(r):
					cstack.push(Rectangle(r.clone()));

				//- Ellipse Operation
				case Ellipse(r):
					cstack.push(Ellipse(r.clone()));

				//- Sub Path
				case SubPath(sub):
					cstack.push(SubPath(sub.clone()));

				/* == StyleAleration Operation == */
				case StyleAlteration(change):
					switch (change) {
						case LineColor( color ):
							cstack.push(StyleAlteration(LineColor(color.clone())));

						case LineWidth( nwidth ):
							cstack.push(StyleAlteration(LineWidth(nwidth)));

						default:
							throw 'PathError: Cannot clone Style Alteration $change!';
					}

				/* == PathStroke Operation == */
				case StrokePath:
					cstack.push(StrokePath);

				/* == Anything Else == */
				default:
					throw 'PathError: Cannot clone Path Component $op!';
			}
		}

		//- assign [copy]'s new "stack" field
		copy.ops = new Queue();
		copy.ops.append( cstack );
		copy._vectorized = _vectorized;

		return copy;
	}

	/**
	  * Vectorize [this] Path
	  */
	public function vectorize():Bool {
		//- variable to store whether vectorization has failed
		var success:Bool = true;

		var nstack:Array<PathComponent> = new Array();

		//- iterate over all operations in [this] Stack
		for (op in stack) {
			//- attempt to vectorize [op]
			try {
				var vop:PathComponent = vectorizeComponent( op );
				nstack.push( vop );
			} 
			//- if said attempt fails
			catch (error : String) {
				//- stop iteration, and mark vectorization as failed
				success = false;
				break;
			}
		}

		//- if vectorization was successful, mark [this] Path as vectorized
		if (success) {
			_vectorized = true;
			stack = nstack;
		}

		return success;
	}

	/**
	  * Vectorize a component of [this] Path
	  */
	private function vectorizeComponent(op : PathComponent):PathComponent {
		//- if no 'graphics' field was provided, vectorization cannot be performed
		if (!graphics.exists) {
			throw 'PathError: Cannot vectorize $op without a "graphics" field!';
		}
		//- alias to [graphics]
		var g:TGraphics = graphics;

		//- vectorize [op]
		switch (op) {
			//- MoveTo
			case MoveTo( pos ):
				pos = pos.vectorize([0, 0, g.width, g.height]);
				return MoveTo(pos);

			//- LineTo
			case LineTo( pos ):
				pos = pos.vectorize([0, 0, g.width, g.height]);
				return LineTo(pos);

			case Rectangle(r):
				return Rectangle(r.vectorize([0, 0, g.width, g.height]));

			case Ellipse(r):
				return Ellipse(r.vectorize([0, 0, g.width, g.height]));

			case SubPath( sub ):
				var vsub = sub.clone();
				vsub.vectorize();
				return SubPath( vsub );

			//- Anything Else
			default:
				return op;
		}
	}

	/**
	  * Devectorize [this] Path
	  */
	public function devectorize():Void {
		//- if [this] Path isn't vectorized, complain about it
		if (!vectorized) {
			throw 'PathError: Cannot devectorize a GraphicsPath which is not vectorized!';
		}

		var success:Bool = true;
		var nstack:Array<PathComponent> = new Array();

		for (op in stack) {
			try {
				var dop:PathComponent = devectorizeComponent( op );
				nstack.push( dop );
			}
			catch (error : String) {
				success = false;
				break;
			}
		}

		if (success) {
			_vectorized = false;
			stack = nstack;
		}
	}

	/**
	  * Devectorize the given PathComponent
	  */
	public function devectorizeComponent(op : PathComponent):PathComponent {
		if (!graphics.exists) {
			throw 'PathError: Cannot devectorize a GraphicsPath which does not have a \'graphics\' field!';
		}

		var g:TGraphics = graphics;

		switch (op) {
			/* == MoveTo Operation == */
			case MoveTo( pos ):
				 return MoveTo(pos.devectorize([0, 0, g.width, g.height]));

			case LineTo( pos ):
				 return LineTo(pos.devectorize([0, 0, g.width, g.height]));

			case Rectangle(r):
				return Rectangle(r.devectorize([0, 0, g.width, g.height]));

			case Ellipse(r):
				return Ellipse(r.devectorize([0, 0, g.width, g.height]));

			case SubPath( sub ):
				var vsub = sub.clone();
				vsub.devectorize();
				return SubPath( vsub );

			default:
				 return op;
		}
	}

/* === Computed Instance Fields === */

	/**
	  * The 'Stack' of Operations currently being operated on
	  */
	public var stack(get, set):Array<PathComponent>;
	private function get_stack():Array<PathComponent> {
		if (!ops.last.exists) {
			ops.append([]);
		}
		return ops.last;
	}
	private function set_stack(nstack : Array<PathComponent>):Array<PathComponent> {
		ops.last = (cast nstack);
		return ops.last;
	}

	/**
	  * Whether [this] Path is vectorized, currently
	  */
	public var vectorized(get, never):Bool;
	private function get_vectorized():Bool {
		return (_vectorized);
	}

	/**
	  * Whether [this] Path is nested within another
	  */
	public var nested(get, never):Bool;
	private inline function get_nested():Bool {
		return (parent != null);
	}

/* === Instance Fields === */

	//- The Queue of States of [this] GraphicsPath
	private var ops : Queue<Array<PathComponent>>;

	//- Optional Pointer to an instance of TGraphics
	public var graphics : Maybe<TGraphics>;

	//- Whether [this] Path is vectorized
	private var _vectorized : Bool;

	//- Parent Path (if any)
	private var parent : Null<GraphicsPath>;
}