package tannus.graphics;

import Std.*;
import tannus.math.TMath.*;

import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
using Math;
using tannus.math.TMath;
using tannus.macro.MacroTools;
using haxe.macro.ExprTools;

class ColorTools {
/* === Static Methods === */

	public static macro function with(color:ExprOf<Col>, action:Expr):Expr {
		action = action.replace(macro red, macro $color[0]);
		action = action.replace(macro green, macro $color[1]);
		action = action.replace(macro blue, macro $color[2]);
		return action;
	}

	/* get brightness */
	public static inline function brightness(c : Col):Int {
		return with(c, ((3 * red + 4 * green + blue) >>> 3));
	}

	/* invert */
	public static inline function invert(c : Col):Col {
		return with(c.copy(), [255-red, 255-green, 255-blue]);
	}

	/* mix two colors */
	public static inline function mix(l:Col, r:Col, n:Float):Col {
		return [
			l[0].lerp(r[0], n).floor().clamp(0, 255),
			l[1].lerp(r[1], n).floor().clamp(0, 255),
			l[2].lerp(r[2], n).floor().clamp(0, 255)
		];
	}

	/* greyscale */
	public static inline function greyscale(c:Col, n:Float):Col {
		var b = brightness( c );
		return with(c, [
			b.lerp(red, n).floor().clamp(0, 255),
			b.lerp(green, n).floor().clamp(0, 255),
			b.lerp(blue, n).floor().clamp(0, 255)
		]);
	}

	/* lighten */
	public static inline function lighten(c:Col, n:Float):Col {
		return with(c, [
			int(red * (100 + n) / 100).clamp(0, 255),
			int(green * (100 + n) / 100).clamp(0, 255),
			int(blue * (100 + n) / 100).clamp(0, 255)
		]);
	}

	public static inline function darken(c:Col, n:Float):Col {
		return lighten(c, -n);
	}
}

private typedef Col = Array<Int>;
