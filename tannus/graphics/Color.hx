package tannus.graphics;

import tannus.math.TMath;
import tannus.math.Percent;

import tannus.io.Ptr;
import tannus.io.ByteArray;
import tannus.io.RegEx;

import Std.*;

using StringTools;
using tannus.ds.StringUtils;
using tannus.math.TMath;

/**
  * Class to represent a color in either RGB or RGBA
  */
@:forward
abstract Color (TColor) from TColor to TColor {
	/* Constructor Function */
	public inline function new(r:Int=0, g:Int=0, b:Int=0, ?a:Int):Void {
		this = new TColor(r, g, b, a);
	}

/* === Instance Methods === */
	
	/**
	  * Creates and returns a 'clone' of [this] Color
	  */
	public inline function clone():Color {
		return cast this.clone();
	}

	/**
	  * Compare two Color objects
	  */
	@:op(A == B)
	public inline function equals(other : Color) return this.equals(other);

	/**
	  * Invert [this] Color
	  */
	@:op(!A)
	public inline function invert():Color return this.invert();

	/**
	  * Mix [this] with another Color
	  */
	public inline function mix(other:Color, ratio:Percent):Color {
		return this.mix(other, ratio);
	}

	/**
	  * Lighten [this] Color
	  */
	public inline function lighten(amount : Float) return this.lighten(amount);

	/**
	  * Darken [this] Color
	  */
	public inline function darken(amount : Float) return this.darken(amount);

/* === Implicit Type Casting === */

	/**
	  * Casting to a String
	  */
	@:to
	public inline function toString():String return this.toString();

	/**
	  * Casting to a ByteArray
	  */
	@:to
	public function toByteArray():ByteArray {
		return toString();
	}

	/* To Int */
	@:to
	public inline function toInt():Int return this.toInt();

	/* From Int */
	/* BUG -- Unfortunately, this method cannot handle alpha, and I don't know of an elegant workaround to this as of now */
	@:from
	public static inline function fromInt(color : Int):Color {
		return new Color((color >> 16 & 0xFF), (color >> 8 & 0xFF), (color & 0xFF));
	}


	/**
	  * Casting from a String
	  */
	@:from
	public static inline function fromString(s : String):Color {
		return TColor.fromString( s );
	}


	#if java

	/* To java.awt.Color */
	@:to
	public function toJavaColor():java.awt.Color {
		return (channels < 4 ? new java.awt.Color(red, green, blue) : new java.awt.Color(red, green, blue, alpha));
	}

	/* From java.awt.Color */
	@:from
	public static inline function fromJavaColor(col : java.awt.Color):Color {
		return new Color(col.getRed(), col.getGreen(), col.getBlue(), col.getAlpha());
	}

	#end
}

private class TColor {
	/* Constructor Function */
	public function new(r:Int=0, g:Int=0, b:Int=0, ?a:Int):Void {
		red = r;
		green = g;
		blue = b;
		alpha = a;
	}

/* === Instance Methods === */

	/**
	  * Create a copy of [this] Color
	  */
	public function clone():TColor {
		return new TColor(red, green, blue, alpha);
	}

	/**
	  * Check whether [this] Color equals some other Color
	  */
	public function equals(other : TColor):Bool {
		return (
			(red == other.red) &&
			(green == other.green) &&
			(blue == other.blue) &&
			((alpha != null) ? alpha == other.alpha : true)
		);
	}

	/**
	  * Mix [this] Color with another one
	  */
	public function mix(t:TColor, weight:Percent):Color {
		var ratio:Float = weight.of( 1 );
		return new TColor(
			int(red + (t.red - red) * ratio),
			int(green + (t.green - green) * ratio),
			int(blue + (t.blue - blue) * ratio),
			int(alpha + (t.alpha - alpha) * ratio)
		);
	}

	/**
	  * Convert [this] to a String
	  */
	public function toString():String {
		if (alpha == null) {
			var out:String = '#';
			out += hex(red, 2);
			out += hex(green, 2);
			out += hex(blue, 2);
			return out;
		}
		else {
			var out:String = 'rgba($red, $green, $blue, ${TMath.roundFloat(Percent.percent(alpha, 255).of(1), 2)})';
			return out;
		}
	}

	/**
	  * Convert [this] to an Int
	  */
	public function toInt():Int {
		if (alpha == null) {
			return (Math.round(red) << 16) | (Math.round(green) << 8) | Math.round(blue);
		} 
		else {
			return ((Math.round(red) << 16) | (Math.round(green) << 8) | Math.round(blue) | Math.round(alpha) << 24);
		}
	}

	/**
	  * Brighten [this] Color
	  */
	public function lighten(amount : Float):TColor {
		var col:TColor = clone();
		
		// amount.value += 100;
		var red = int(col.red * (100 + amount) / 100);
		var green = int(col.green * (100 + amount) / 100);
		var blue = int(col.blue * (100 + amount) / 100);

		col.red = red;
		col.green = green;
		col.blue = blue;

		return col;
	}

	/**
	  * Darken [this] Color
	  */
	public function darken(amount : Float):TColor {
		return lighten(0 - amount);
	}

	/**
	  * Invert [this] Color
	  */
	public function invert():TColor {
		return new TColor(255-red, 255-green, 255-blue, alpha);
	}

/* === Computed Instance Fields === */

	/* red component */
	public var red(get, set):Int;
	private inline function get_red() return _red;
	private inline function set_red(v : Int):Int {
		return (_red = v.clamp(0, 255));
	}

	/* green component */
	public var green(get, set):Int;
	private inline function get_green() return _green;
	private inline function set_green(v : Int):Int {
		return (_green = v.clamp(0, 255));
	}

	/* blue component */
	public var blue(get, set):Int;
	private inline function get_blue() return _blue;
	private inline function set_blue(v : Int):Int {
		return (_blue = v.clamp(0, 255));
	}

	/* alpha component */
	public var alpha(get, set):Null<Int>;
	private inline function get_alpha() return _alpha;
	private inline function set_alpha(v : Null<Int>):Null<Int> {
		return (_alpha = (v!=null?v.clamp(0, 255):null));
	}

/* === Instance Fields === */

	private var _red : Int;
	private var _green : Int;
	private var _blue : Int;
	private var _alpha : Null<Int>;

/* === Static Methods === */

	/**
	  * Create a new Color from a String
	  */
	public static function fromString(_s : String):TColor {
		//- Colors in HEX format
		if (_s.startsWith('#')) {
			//- strip off the '#'
			var s = _s.replace('#', '');

			//- determine what to do based on the length of the remaining String
			switch (s.length) {
				//- Standard 6-digit HEX
				case 6:
					//- divvy the String up into three parts
					var parts:Array<String> = new Array();
					var chars:Array<String> = s.split('');

					parts.push(chars.shift()+chars.shift());
					parts.push(chars.shift()+chars.shift());
					parts.push(chars.shift()+chars.shift());

					var channels:Array<Int> = new Array();
					for (part in parts) {
						var channel:Int = Std.parseInt('0x'+part);
						channels.push( channel );
					}

					return new TColor(channels[0], channels[1], channels[2]);

				//- 3-digit shorthand
				case 3:
					//- divvy the String up into three parts
					var parts:Array<String> = new Array();
					var chars:Array<String> = s.split('');

					parts.push(chars.shift());
					parts.push(chars.shift());
					parts.push(chars.shift());
					parts = parts.map(function(c) return (c + c));

					var channels:Array<Int> = new Array();
					for (part in parts) {
						var channel:Int = Std.parseInt('0x'+part);
						channels.push( channel );
					}

					return new TColor(channels[0], channels[1], channels[2]);				

				default:
					throw 'ColorError: Cannot create Color from "$s"!';
			}
		}

		//- Otherwise
		else {
			var s:String = _s;
			var rgb:RegEx = ~/rgb\( ?([0-9]+), ?([0-9]+), ?([0-9]+) ?\)/i;
			var rgba:RegEx =  ~/rgba\( ?([0-9]+), ?([0-9]+), ?([0-9]+), ?([0-9]+) ?\)/i;

			/* rgb([r], [g], [b]) Notation */
			if (rgb.match(s)) {
				var data = rgb.matches( s )[0];
				trace( data );
				var i = Std.parseInt.bind(_);
				return new TColor(i(data[1]), i(data[2]), i(data[3]));
			}
			else if (rgba.match(s)) {
				var data = rgba.matches( s )[0];
				trace( data );
				var i = Std.parseInt.bind(_);
				return new TColor(i(data[1]), i(data[2]), i(data[3]), i(data[4]));
			}
			else {
				throw 'ColorError: Cannot create Color from "$s"!';
			}
		}
	}

	/**
	  * Create a Color from an Int
	  * BUG: Unfortunately, this method can't handle alpha, and I don't know how to fix this as of now
	  */
	public static function fromInt(color : Int):TColor {
		return new Color((color >> 16 & 0xFF), (color >> 8 & 0xFF), (color & 0xFF));
	}

	/**
	  * Utility method to get HEX Strings from Ints, since Python target has a bug in this behaviour
	  */
	private static function hex(val:Int, digits:Int):String {
		#if python
			var _v:Int = val;
			var _d:Int = digits;
			var h:String = python.Syntax.pythonCode('hex(_v).replace("0x", "").upper()');
			return h;
		#else
			return StringTools.hex(val, digits);
		#end
	}
}
