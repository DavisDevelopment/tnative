package tannus.geom;

import tannus.geom.Point;

/**
  * Coordinate Matrix class
  */
class Matrix {
	/* Constructor Function */
	public function new (a:Float = 1, b:Float = 0, c:Float = 0, d:Float = 1, tx:Float = 0, ty:Float = 0) {
		this.a = a;
		this.b = b;
		this.c = c;
		this.d = d;
		this.tx = tx;
		this.ty = ty;
	}
	
	/**
	  * Creates and returns an exact copy of [this] Matrix
	  */
	public inline function clone ():Matrix {
		return new Matrix (a, b, c, d, tx, ty);
	}
	
	/**
	  * Concatenate [this] Matrix with [m], effectively combining the geometric effects of the two
	  */
	public function concat(m : Matrix):Void {
		var a1 = a * m.a + b * m.c;
		b = a * m.b + b * m.d;
		a = a1;

		var c1 = c * m.a + d * m.c;
		d = c * m.b + d * m.d;
		c = c1;
		
		var tx1 = tx * m.a + ty * m.c + m.tx;
		ty = tx * m.b + ty * m.d + m.ty;
		tx = tx1;
	}
	
	
	/**
	  * Clones the state of [sourceMatrix] onto [this]
	  */
	public function copyFrom(sourceMatrix : Matrix):Void {
		a = sourceMatrix.a;
		b = sourceMatrix.b;
		c = sourceMatrix.c;
		d = sourceMatrix.d;
		tx = sourceMatrix.tx;
		ty = sourceMatrix.ty;
	}
	
	
	public function createBox(scaleX:Float, scaleY:Float, rotation:Float = 0, tx:Float = 0, ty:Float = 0):Void {
		a = scaleX;
		d = scaleY;
		b = rotation;
		this.tx = tx;
		this.ty = ty;
	}
	
	public function createGradientBox (width:Float, height:Float, rotation:Float = 0, tx:Float = 0, ty:Float = 0):Void {
		a = width / 1638.4;
		d = height / 1638.4;
		
		// rotation is clockwise
		if (rotation != 0) {
			var cos = Math.cos (rotation);
			var sin = Math.sin (rotation);
			
			b = sin * d;
			c = -sin * a;
			a *= cos;
			d *= cos;
			
		} 
		// rotation is counter-clockwise
		else {
			b = 0;
			c = 0;
		}
		
		this.tx = tx + width / 2;
		this.ty = ty + height / 2;
	}
	
	/**
	  * Determine whether [this] Matrix is equal to [matrix]
	  */
	public function equals(matrix : Matrix):Bool {
		return (matrix != null && tx == matrix.tx && ty == matrix.ty && a == matrix.a && b == matrix.b && c == matrix.c && d == matrix.d);
	}
	
	/**
	  * Transform the state of [this] Matrix such that it causes no geometric transformations
	  */
	public function identity ():Void {
		a = 1;
		b = 0;
		c = 0;
		d = 1;
		tx = 0;
		ty = 0;
	}
	
	/**
	  * Transform [this] Matrix into, effectively, the opposite of itself
	  */
	public function invert ():Matrix {
		var norm = a * d - b * c;
		
		if (norm == 0) {
			
			a = b = c = d = 0;
			tx = -tx;
			ty = -ty;
			
		}
		else {
			norm = 1.0 / norm;
			var a1 = d * norm;
			d = a * norm;
			a = a1;
			b *= -norm;
			c *= -norm;
			
			var tx1 = - a * tx - c * ty;
			ty = - b * tx - d * ty;
			tx = tx1;	
		}
		
		//__cleanValues ();
		
		return this;
	}
	
	/**
	  * Do the stuff
	  */
	public inline function mult (m : Matrix):Matrix {
		var result = clone();
		result.concat( m );
		return result;
	}
	
	/**
	  * Apply a rotation transform to [this] Matrix
	  */
	public function rotate (theta:Float):Void {
		/*
		   Rotate object "after" other transforms
			
		   [  a  b   0 ][  ma mb  0 ]
		   [  c  d   0 ][  mc md  0 ]
		   [  tx ty  1 ][  mtx mty 1 ]
			
		   ma = md = cos
		   mb = sin
		   mc = -sin
		   mtx = my = 0
			
		 */
		
		var cos = Math.cos (theta);
		var sin = Math.sin (theta);
		
		var a1 = a * cos - b * sin;
		b = a * sin + b * cos;
		a = a1;
		
		var c1 = c * cos - d * sin;
		d = c * sin + d * cos;
		c = c1;
		
		var tx1 = tx * cos - ty * sin;
		ty = tx * sin + ty * cos;
		tx = tx1;
	}
	
	/**
	  * Apply a scaling transform to [this] Matrix
	  */
	public function scale(sx:Float, sy:Float):Void {
		/*
		   Scale object "after" other transforms
			
		   [  a  b   0 ][  sx  0   0 ]
		   [  c  d   0 ][  0   sy  0 ]
		   [  tx ty  1 ][  0   0   1 ]
		 */
		
		a *= sx;
		b *= sy;
		c *= sx;
		d *= sy;
		tx *= sx;
		ty *= sy;
	}
	
	/**
	  * Sets the rotation, presumably
	  */
	private inline function setRotation(theta:Float, scale:Float = 1) {
		a = Math.cos (theta) * scale;
		c = Math.sin (theta) * scale;
		b = -c;
		d = a;
	}
	
	/**
	  * Explicitly assign the fields of [this] Matrix
	  */
	public function setTo(a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float):Void {
		this.a = a;
		this.b = b;
		this.c = c;
		this.d = d;
		this.tx = tx;
		this.ty = ty;
	}
	
	/**
	  * Convert [this] Matrix into a human-readable String
	  */
	public inline function toString ():String {
		return "Matrix(" + a + ", " + b + ", " + c + ", " + d + ", " + tx + ", " + ty + ")";
	}
	
	/**
	  * Transform the given Point using [this] Matrix
	  */
	public function transformPoint(pos:Point, ?newpos:Point):Point {
		if (newpos == null) {
			newpos = new Point();
		}

		var x = pos.x, y = pos.y;
		
		newpos.x = (a * x + c * y + tx);
		newpos.y = (b * x + d * y + ty);

		return newpos;
	}
	
	/**
	  * Translates the Matrix along the 'x' and 'y' axis
	  */
	public function translate (dx:Float, dy:Float) {
		var m = new Matrix ();
		m.tx = dx;
		m.ty = dy;
		this.concat (m);
	}
	
	/**
	  * Do the stuff
	  */
	private inline function __cleanValues ():Void {
		a = Math.round (a * 1000) / 1000;
		b = Math.round (b * 1000) / 1000;
		c = Math.round (c * 1000) / 1000;
		d = Math.round (d * 1000) / 1000;
		tx = Math.round (tx * 10) / 10;
		ty = Math.round (ty * 10) / 10;
	}
	
/* === Instance Fields === */
	
	//- The value that affects the positioning of pixels along the x axis when scaling or rotating an image
	public var a:Float;

	//- The value that affects the positioning of pixels along the y axis when rotating or skewing an image
	public var b:Float;

	//- The value that affects the positioning of pixels along the x axis when rotating or skewing an image
	public var c:Float;

	//- The value that affects the positioning of pixels along the y axis when scaling or rotating an image
	public var d:Float;

	//- The distance by which to translate each point along the x axis
	public var tx:Float;

	//- The distance by which to translate each point along the y axis
	public var ty:Float;
	
	private static var __identity = new Matrix ();
}
