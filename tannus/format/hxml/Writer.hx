package tannus.format.hxml;

import tannus.format.Writer;
import tannus.io.ByteArray;
import tannus.internal.BuildFile;
import tannus.internal.BuildComponent;

class Writer extends tannus.format.Writer {
	public function new():Void {
		super();
		data = new ByteArray();
	}

	public function generate(bf : BuildFile):ByteArray {
		for (c in bf.comps) {
			genComponent( c );
		}

		return data;
	}

	public function genComponent(c : BuildComponent):Void {
		switch (c) {
			case Comp.BCMain( cref ):
				data.appendString('-main $cref\n');

			case Comp.BCClassPath( dir ):
				data.appendString('-cp $dir\n');

			case Comp.BCDef( name ):
				data.appendString('-D $name\n');

			case Comp.BCMacro( code ):
				data.appendString('--macro $code\n');

			case Comp.BCDebug:
				data.appendString('-debug\n');

			case Comp.BCTarget(t, d):
				data.appendString('-$t $d\n');

			default:
				throw 'HXMLError: $c not yet implemented!';
		}
	}

/* === Instance Fields === */

	private var data : ByteArray;
}

private typedef Comp = BuildComponent;
