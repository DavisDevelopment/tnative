package tannus.graphics;

import tannus.math.TMath;
import tannus.math.Percent;

import tannus.io.Ptr;
import tannus.io.ByteArray;
import tannus.io.RegEx;
import tannus.geom.Point;

import Std.*;
import Math.*;
import tannus.math.TMath;

import haxe.macro.Expr;

using StringTools;
using tannus.ds.StringUtils;
using tannus.ds.ArrayTools;
using tannus.math.TMath;
using tannus.macro.MacroTools;

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

	/* create linked color */
	public static inline function _linked(r:Ptr<Int>, g:Ptr<Int>, b:Ptr<Int>, ?a:Ptr<Int>):Color {
		return cast new LinkedColor(r, g, b, a);
	}

	public static macro function linked(r:ExprOf<Int>, others:Array<ExprOf<Int>>):ExprOf<Color> {
		var args:Array<ExprOf<Ptr<Int>>> = ([r].concat(others)).map(function(e) return e.pointer());
		return macro tannus.graphics.Color._linked( $a{args} );
	}
}

@:expose( 'Color' )
private class TColor implements tannus.ds.Comparable<TColor> {
	/* Constructor Function */
	public function new(r:Int=0, g:Int=0, b:Int=0, ?a:Int, noset:Bool=false):Void {
		if ( !noset ) {
			red = r;
			green = g;
			blue = b;
			alpha = a;
		}
	}

/* === Instance Methods === */

	/**
	  * Create a copy of [this] Color
	  */
	public function clone():TColor {
		return new TColor(red, green, blue, alpha);
	}

	/**
	  * copy data from [other] onto [this]
	  */
	public function copyFrom(other : Color):Void {
		red = other.red;
		green = other.green;
		blue = other.blue;
		alpha = other.alpha;
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
		var ratio:Float = weight.of( 1.0 );
		return new TColor(
			int(red.lerp(t.red, ratio)),
			int(green.lerp(t.green, ratio)),
			int(blue.lerp(t.blue, ratio)),
			alpha
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

	/**
	  * calculate the luminance of [this] Color
	  */
	public inline function luminance():Float {
		return ((0.2126 * red) + (0.7152 * green) + (0.0722 * blue));
	}

	/**
	  * calculate the brightness of [this] Color
	  */
	public inline function brightness():Int {
		return int(((red * 299) + (green * 587) + (blue * 114)) / 1000);
	}

	/**
	  * convert [this] Color to the HSL scheme
	  */
	public function toHsl():Hsl {
		var chan = [red, green, blue].macmap(_ / 255.0);
		var r:Float = chan[0], g:Float = chan[1], b:Float = chan[2];
		var cmax = chan.max(function(n) return n);
		var cmin = chan.min(function(n) return n);
		var l = (cmax + cmin) / 2;
		var h:Float, s:Float;
		if (cmax == cmin) {
			h = s = 0;
		}
		else {
			var d = (cmax - cmin);
			s = (d > 0.5 ? (d / (2 - cmax - cmin)) : (d / (cmax + cmin)));
			if (cmax == r)
				h = ((g - b) / d + (g < b ? 6 : 0)); 
			else if (cmax == g) 
				h = ((b - r) / d + 2);
			else if (cmax == b)
				h = ((r - g) / d + 4);
			else
				h = 0;
			h /= 6;
		}

		return {
			'hue': h,
			'saturation': s,
			'lightness': l
		};
	}

	/**
	  * get the XYZ values of [this] Color
	  */
	public function getXYZ():Point {
		var vals = [red, green, blue].macmap(_ / 255);
		vals = vals.macmap({
			if (_ > 0.04045) {
				return pow(((_ + 0.0555) / 1.055), 2.4);
			}
			else {
				return (_ / 12.92);
			}
		});
		vals = vals.macmap(_ * 100);
		var r = vals[0];
		var g = vals[1];
		var b = vals[2];

		var x = ((r * 0.4124) + (g * 0.3576) + (b * 0.1805));
		var y = ((r * 0.2126) + (g * 0.7152) + (b * 0.0722));
		var z = ((r * 0.0193) + (g * 0.1192) + (b * 0.9505));

		return new Point(x, y, z);
	}

	/**
	  * get the LAB values of [this] Color
	  */
	public function getLab():Lab {
		var p = getXYZ();
		var vals = [(p.x / 95.047), (p.y / 100), (p.z / 108.883)];
		vals = vals.macmap({
			if (_ > 0.008856) {
				pow(_, (1 / 3));
			}
			else {
				((7.787 * _) + (16 / 116));
			}
		});
		var l = (116 * vals[1] - 16);
		var a = (500 * (vals[0] - vals[1]));
		var b = (200 * (vals[1] - vals[2]));
		return {
			'l': l,
			'a': a,
			'b': b
		};
	}

	/**
	  * get the delta-e between [this] Color and other 
	  */
	public function cie1994(other : Color):Float {
		var x = this.getLab();
		var y = other.getLab();
		var k2:Float = 0.015;
		var k1:Float = 0.045;
		var kl:Float = 1;
		var kh:Float = 1;
		var kc:Float = 1;
		var c1 = sqrt(x.a * x.a + x.b * x.b);
		var c2 = sqrt(y.a * y.a + y.b * y.b);
		var sh = (1 + k2 * c1);
		var sc = (1 + k1 * c1);
		var sl = 1;
		var da = (x.a - y.a);
		var db = (x.b - y.b);
		var dc = (c1 - c2);
		var dl = (x.l - y.l);
		var dh = sqrt(pow(da, 2) + pow(db, 2) + pow(dc, 2));
		return (sqrt(
			pow((dl / (kl * sl)), 2) + 
			pow((dc / (kc * sc)), 2) + 
			pow((dh / (kh * sh)), 2)
		) / 10);
	}

	/**
	  * greyscale [this] Color
	  */
	public function greyscale():Color {
		var gray = clone();
		var avg = int(gray.channels.average());
		gray.channels = [avg, avg, avg];
		return gray;
	}

	/**
	  * do some number magic
	  */
	private function bound(n:Int, max:Int):Int {
		if (abs(n - max) < 0.000001)
			return 1;
		return int((n % max) / (max + 0.0));
	}

/* === Computed Instance Fields === */

	/* red component */
	public var red(get, set):Int;
	private function get_red() return _red;
	private function set_red(v : Int):Int {
		return (_red = v.clamp(0, 255));
	}

	/* green component */
	public var green(get, set):Int;
	private function get_green() return _green;
	private function set_green(v : Int):Int {
		return (_green = v.clamp(0, 255));
	}

	/* blue component */
	public var blue(get, set):Int;
	private function get_blue() return _blue;
	private function set_blue(v : Int):Int {
		return (_blue = v.clamp(0, 255));
	}

	/* alpha component */
	public var alpha(get, set):Null<Int>;
	private function get_alpha() return _alpha;
	private function set_alpha(v : Null<Int>):Null<Int> {
		return (_alpha = (v!=null?v.clamp(0, 255):null));
	}

	/* all channels */
	public var channels(get, set):Array<Int>;
	private inline function get_channels():Array<Int> return [red, green, blue];
	private function set_channels(v : Array<Int>):Array<Int> {
		red = v[0];
		green = v[1];
		blue = v[2];
		return channels;
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

/**
  * Color whose 'red', 'green', 'blue', and 'alpha' fields are bound to external data
  */
class LinkedColor extends TColor {
	/* Constructor Function */
	public function new(r:Ptr<Int>, g:Ptr<Int>, b:Ptr<Int>, ?a:Ptr<Int>):Void {
		super(0, 0, 0, null, true);
		_a = Ptr.to( null );
		_r = r;
		_g = g;
		_b = b;
		if (a != null) {
			_a = a;
		}
	}

/* === Instance Methods === */

	override private function get_red():Int return _r.get();
	override private function set_red(v : Int):Int return _r.set(v.clamp(0, 255));

	override private function get_green():Int return _g.get();
	override private function set_green(v : Int):Int return _g.set(v.clamp(0, 255));

	override private function get_blue():Int return _b.get();
	override private function set_blue(v : Int):Int return _b.set(v.clamp(0, 255));

	override private function get_alpha():Null<Int> return _a.get();
	override private function set_alpha(v : Null<Int>):Null<Int> return _a.set(v.clamp(0, 255));

/* === Instance Fields === */

	private var _r : Ptr<Int>;
	private var _g : Ptr<Int>;
	private var _b : Ptr<Int>;
	private var _a : Ptr<Null<Int>>;
}

typedef Hsl = {
	hue : Float,
	saturation : Float,
	lightness : Float
};

typedef Lab = {
	l : Float,
	a : Float,
	b : Float
};
