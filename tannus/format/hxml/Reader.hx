package tannus.format.hxml;

import tannus.internal.BuildFile;
import tannus.internal.BuildComponent;
import tannus.internal.BuildFlag;
import tannus.internal.BuildOperation;

import tannus.io.ByteArray;
import tannus.io.Byte;
import tannus.io.RegEx;
import tannus.sys.Path;

using StringTools;
using Lambda;
using tannus.ds.ArrayTools;
using tannus.ds.StringUtils;

class Reader {
	/* Constructor Function */
	public function new():Void {
			
	}

/* === Instance Methods === */

	/**
	  * Parse HXML Code
	  */
	public function read(hxmlCode : ByteArray):BuildFile {
		var all_targets:Array<String> = ['js', 'as3', 'swf', 'python', 'php', 'java', 'neko', 'cpp'];
		var bf = new BuildFile();
		var lines:Array<String> = hxmlCode.toString().split('\n');
		lines = lines.map(function(l) return l.trim()).filter(function(s) return (s != ''));
		for (line in lines) {
			var werds = line.split(' ');
			var com:String = werds.shift();
			var rest:String = werds.join(' ');

			switch (com) {
				case '-main':
					bf.main(rest.trim());

				case '-cp':
					bf.cp(rest.trim());

				case '-D':
					bf.def(rest.trim());

				case '-debug':
					bf.debug();

				case '--next':
					bf.next();

				case (_.toLowerCase().substring(1) => target) if (target != '' && all_targets.has(target)):
					bf.target(target, rest.trim());

				default:
					if (com != '') {
						var e:String = 'HXMLError: Unrecognized directive "$com"';
						trace( e );
						throw e;
					} else continue;
			}
		}

		return bf;
	}
}
