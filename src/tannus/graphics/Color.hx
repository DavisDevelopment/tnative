package tannus.graphics;

import tannus.math.TMath;
import tannus.math.Percent;

import tannus.io.Ptr;
import tannus.io.ByteArray;

using StringTools;

/**
  * Class to represent a color in either RGB or RGBA
  */
abstract Color (Array<Int>) {
	/* Constructor Function */
	public inline function new(?r:Int=0, ?g:Int=0, ?b:Int=0, ?a:Int):Void {
		this = [r, g, b, a];
	}

/* === Instance Fields === */

	/**
	  * The red channel
	  */
	public var red(get, set):Int;
	private inline function get_red():Int return getValue(0);
	private inline function set_red(nr:Int) return setValue(0, nr);

	/**
	  * The green channel
	  */
	public var green(get, set):Int;
	private inline function get_green():Int return getValue(1);
	private inline function set_green(ng:Int) return setValue(1, ng);

	/**
	  * The blue channel
	  */
	public var blue(get, set):Int;
	private inline function get_blue():Int return getValue(2);
	private inline function set_blue(nb:Int) return setValue(2, nb);

	/**
	  * The alpha channel
	  */
	public var alpha(get, set):Int;
	private inline function get_alpha():Int {
		var a:Null<Int> = getValue(3);
		return (a == null ? setValue(3, 255) : a);
	}
	private inline function set_alpha(na : Int):Int {
		return setValue(3, na);
	}

	/**
	  * The number of channels available currently on [this] Color
	  */
	public var channels(get, never):Int;
	private inline function get_channels():Int {
		return (this.length);
	}

/* === Instance Methods === */
	
	/**
	  * Get the value of a given channel of [this] Color
	  */
	private inline function getValue(channel : Int):Int {
		return this[channel];
	}

	/**
	  * Set the value of a given chanel of [this] Color
	  */
	private inline function setValue(channel:Int, val:Int):Int {
		this[channel] = TMath.clamp(val, 0, 255);
		return this[channel];
	}

/* === Implicit Type Casting === */

	/**
	  * Casting to a String
	  */
	@:to
	public function toString():String {
		if (channels == 3) {
			var out:String = '#';
			
			for (c in this) {
				var piece:String = hex(c, 2);

				out += piece;
			}

			return out;
		}
		else if (channels == 4) {
			var out:String = 'rgba(';

			var i:Int = 0;
			for (c in this) {
				if (i == 3) {
					var n:Percent = Percent.percent(alpha, 255);
					var i:Float = n.of( 1 );
					trace( i );
					var piece:String = (i+'');
					out += piece;

				} else {
					var piece:String = hex(c, 2);
					
					out += ('$piece, ');
				}
				i++;
			}
			
			out += ')';
			return out;
		}
		else {
			throw 'ColorError: Cannot cast a Color with $channels channels to a String!';
		}
	}

	/**
	  * Casting to a ByteArray
	  */
	@:to
	public function toByteArray():ByteArray {
		return toString();
	}


	/**
	  * Casting from a String
	  */
	@:from
	public static function fromString(_s : String):Color {
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
					trace(parts);

					var channels:Array<Int> = new Array();
					for (part in parts) {
						var channel:Int = Std.parseInt('0x'+part);
						channels.push( channel );
					}

					return new Color(channels[0], channels[1], channels[2]);

				//- 3-digit shorthand
				case 3:
					//- divvy the String up into three parts
					var parts:Array<String> = new Array();
					var chars:Array<String> = s.split('');

					parts.push(chars.shift());
					parts.push(chars.shift());
					parts.push(chars.shift());
					parts = parts.map(function(c) return (c + c));
					trace(parts);

					var channels:Array<Int> = new Array();
					for (part in parts) {
						var channel:Int = Std.parseInt('0x'+part);
						trace( channel );
						channels.push( channel );
					}

					return new Color(channels[0], channels[1], channels[2]);				

				default:
					throw 'ColorError: Cannot create Color from "$_s"!';
			}
		}

		//- Otherwise
		else {
			//- Complain about it
			throw 'ColorError: Cannot create Color from "$_s"!';
		}
	}


	/**
	  * Utility method to get HEX Strings from Ints, since Python target has a bug in this behaviour
	  */
	private static function hex(val:Int, digits:Int):String {
		#if python
			var _v:Int = val;
			trace( _v );
			var _d:Int = digits;
			var h:String = python.Syntax.pythonCode('hex(_v).replace("0x", "").upper()');
			return h;
		#else
			return StringTools.hex(val, digits);
		#end
	}
}
