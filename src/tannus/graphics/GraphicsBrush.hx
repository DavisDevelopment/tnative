package tannus.graphics;

import tannus.graphics.Color;
import tannus.graphics.LinearGradient;

abstract GraphicsBrush (Gbt) {
	/* Constructor Function */
	public function new(brush : Gbt):Void {
		this = brush;
	}

/* === Instance Fields === */

	/**
	  * Reference to [this] as a GraphicsBrushType
	  */
	public var type(get, never):Gbt;
	private inline function get_type():Gbt {
		return this;
	}

/* === Instance Methods === */

	/**
	  * Create and return a clone of [this] Brush
	  */
	public function clone():GraphicsBrush {
		switch (this) {
			/* Solid Color Brush */
			case BColor( color ):
				return color.clone();

			default:
				error('Cannot clone Brush of type $this!');
		}
	}

/* === Implicit Type Casting === */

	/**
	  * Casting to a Color object
	  */
	@:to
	public function toColor():Color {
		switch (this) {
			/* Solid Color Brush */
			case BColor(c):
				return c;

			/* Anything Else */
			default:
				cannotCast('tannus.graphics.Color');
		}
	}

	/**
	  * Casting to Strings
	  */
	@:to
	public function toString():String {
		//- How we cast will depend on what type of Brush this is
		switch (this) {
			/* Solid Color Brush */
			case BColor( color ):
				return color.toString();

			/* Anything Else */
			default:
				cannotCast('String');
		}
	}

	/**
	  * Casting to Integers
	  */
	@:to
	public function toInt():Int {
		//- How we cast will depend on what type of Brush [this] is
		switch (type) {
			/* Solid Color Brush */
			case BColor( color ):
				return color.toInt();

			/* Anything Else */
			default:
				cannotCast('Int');
		}
	}

	/**
	  * Casting From Color Objects
	  */
	@:from
	public static inline function fromColor(color : Color):GraphicsBrush {
		return new GraphicsBrush(BColor(color));
	}

	/**
	  * Casting From Linear Gradient
	  */
	@:from
	public static inline function fromLinearGradient(gradient : LinearGradient):GraphicsBrush {
		return new GraphicsBrush(BLinearGradient(gradient));
	}

	/**
	  * Casting From Strings
	  */
	@:from
	public static function fromString(str : String):GraphicsBrush {
		//- Attempt to parse the given String as a Color
		try {
			var color:Color = Color.fromString( str );
			return new GraphicsBrush(BColor(color));
		}

		//- If that fails
		catch (error : String) {
			//- Complain about it
			cannotMake('"$str"');
		}
	}

	/**
	  * Casting From Integers
	  */
	@:from
	public static function fromInt(i : Int):GraphicsBrush {
		//- Attempt to convert the given int to a Color
		try {
			var color:Color = Color.fromInt( i );
			return fromColor(color);
		}
		
		//- If that fails
		catch (error : String) {
			//- Complain about it
			cannotMake('$i');
		}
	}

/* === Error Reporting Methods === */

	/**
	  * Shorthand method to throw an error
	  */
	private static inline function error(msg : String):Void {
		throw 'BrushError: $msg';
	}

	/**
	  * Report that the type of Brush [this] is cannot be cast to the requested type
	  */
	private inline function cannotCast(typ : String):Void {
		error('Cannot cast $type to $typ!');
	}

	/**
	  * Report that a Brush cannot be created from the given type
	  */
	private static inline function cannotMake(type : String):Void {
		error('Cannot create a GraphicsBrush instance from $type!');
	}
}

/* Shorthand to tannus.graphics.GraphicsBrushType */
private typedef Gbt = tannus.graphics.GraphicsBrushType;
