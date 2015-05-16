package tannus.format.hxml;

import tannus.format.Writer;
import tannus.io.ByteArray;
import tannus.internal.BuildFile;
import tannus.internal.BuildComponent;

class Writer extends tannus.format.Writer {
	public function new():Void {
		super();
	}

	public function generate(bf : BuildFile):ByteArray {
		for (c in bf.comps) {
			genComponent( c );
		}

		return this.buffer;
	}

	public function genComponent(c : BuildComponent):Void {
		switch (c) {
			case Comp.BCMain( cref ):
				line('-main $cref');

			case Comp.BCClassPath( dir ):
				line('-cp $dir');

			case Comp.BCDef( name ):
				line('-D $name');

			case Comp.BCMacro( code ):
				line('--macro $code');

			case Comp.BCDebug:
				line('-debug');

			case Comp.BCTarget(t, d):
				line('-$t $d');

			default:
				throw 'HXMLError: $c not yet implemented!';
		}
	}
}

private typedef Comp = BuildComponent;
