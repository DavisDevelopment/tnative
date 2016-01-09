package tannus.xml;

import tannus.xml.Elem;
import tannus.ds.Stack;

using tannus.ds.StringUtils;
using tannus.ds.ArrayTools;

class Printer {
	/* Constructor Function */
	public function new():Void {
		buffer = '';
		history = new Stack();
		space = '   ';
		pretty = false;
	}

/* === Instance Methods === */

	/**
	  * Generate the code for the given Elem
	  */
	public function generate(e : Elem):String {
		buffer = '';
		history = new Stack();

		genElem( e );

		return buffer;
	}

	/**
	  * Generate the code for an Element
	  */
	private function genElem(e:Elem, indent:Int=0):Void {
		var pre:String = space.times( indent );
		if ( pretty )
			indent++;
		var parts = [for (name in e.attributes.keys) (name+'="'+Std.string(e.attributes.get(name))+'"')];
		var open:String = '<${e.tag}';
		if (parts.length > 0) {
			open += ' ';
			open += parts.join(' ');
		}
		open += '>';
		var close:String = '</${e.tag}>';
		var lines = e.text.split( '\n' );
		var txt:String = getElemText(e, indent);

		if (e.children.length > 0) {
			writeln(pre + open + txt);
			for (child in e.children) {
				genElem(child, indent);
			}
			writeln(pre + close);
		}
		else {
			write(pre + open);
			write( txt );
			writeln(pre + close);
			/*
			else {
				var node:String = '<${e.tag}';
				if (parts.length > 0) {
					node += ' ';
					node += parts.join(' ');
				}
				node += '/>';
				writeln(pre + node);
			}
			*/
		}
	}

	/**
	  * Get Element text
	  */
	private function getElemText(e:Elem, indent:Int):String {
		var lines:Array<String> = e.text.split( '\n' );
		var pre:String = space.times( indent );
		if (lines.length > 1) {
			var res:String = '\n';
			for (l in lines)
				res += (pre + l + '\n');
			return res;
		}
		else {
			return e.text;
		}
	}

	/**
	  * Add an entry to the history
	  */
	private inline function save():Void {
		history.add( buffer );
	}

	/**
	  * Restore [this] Printer to it's last history entry
	  */
	private inline function restore():Void {
		buffer = history.pop();
	}

	/**
	  * Write some text to [buffer]
	  */
	private inline function write(s : String):Void {
		buffer += s;
	}

	/**
	  * Write some text, followed by a newline
	  */
	private inline function writeln(s : String):Void {
		write(s + '\n');
	}

/* === Instance Fields === */

	private var history : Stack<String>;
	private var buffer : String;
	public var space : String;
	public var pretty : Bool;

/* === Static Methods === */

	/**
	  * Do the shit
	  */
	public static function print(e:Elem, pretty:Bool=false):String {
		var p = new Printer();
		p.pretty = pretty;
		return p.generate( e );
	}
}
