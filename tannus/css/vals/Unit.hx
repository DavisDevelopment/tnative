package tannus.css.vals;

@:enum
abstract Unit (String) from String to String {
/* === Constructs === */

	var Em = 'em';
	var Ex = 'ex';
	var Ch = 'ch';
	var Rem = 'rem';
	var Vpw = 'vw';
	var Vph = 'vh';
	var Perc = '%';
	var Cm = 'cm';
	var Mm = 'mm';
	var In = 'in';
	var Px = 'px';
	var Pt = 'pt';
	var Pc = 'pc';
	var Deg = 'deg';

/* === Static Methods === */

	/**
	  * Array of all Constructs
	  */
	public static var all(get, never):Array<String>;
	private static inline function get_all():Array<String> {
		return ([
			/* Relative Units */
			'em', 'ex', 'ch', 'rem', 'vw', 'vh', '%',
			/* Absolute Units */
			'cm', 'mm', 'in', 'px', 'pt', 'pc', 'deg'
		]);
	}

	/**
	  * Test whether a given String is a valid Unit
	  */
	public static inline function isValidUnit(s : String):Bool {
		return (Lambda.has(all, s));
	}
}
