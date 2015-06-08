package tannus.ui;

import tannus.ds.Maybe;
import tannus.ds.EitherType;
import tannus.graphics.Color;
import tannus.ui.FontStyle;

class Font {
	/* Constructor Function */
	public function new(?name:Maybe<FName>, ?styl:Maybe<FontStyle>, ?colr:Maybe<Color>, ?siz:Maybe<Float>):Void {
		family = new Array();
		style = (styl || Normal);
		size = (siz || 16);
		color = (colr || '#000');

		if (name.exists) {
			var nam = name.toNonNullable();
			switch (nam.type) {
				case Left( fam ):
					family.push( fam );

				case Right( fams ):
					family = family.concat(fams);
			}
		}
	}

/* === Instance Methods === */

	/**
	  * Add a font-name
	  */
	public function addFamily(nam : FName):Void {
		var add = family.push.bind(_);
		switch (nam.type) {
			case Left( fam ):
				add( fam );

			case Right( fams ):
				for (n in fams) 
					add( n );
		}
	}

	/**
	  * Remove a font-name
	  */
	public function removeFamily(nam : FName):Void {

		nam.switchType(fam, fams, family.remove(fam), (for (n in fams) family.remove(n)));
	}

/* === Instance Fields === */

	/* The exact name of [this] Font */
	public var family:Array<String>;

	/* The style of [this] Font */
	public var style:FontStyle;

	/* The Color of [this] Font */
	public var color:Color;

	/* The size of [this] Font in pixels */
	public var size:Float;
}

private typedef FName = EitherType<String, Array<String>>;
