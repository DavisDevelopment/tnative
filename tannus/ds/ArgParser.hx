package tannus.ds;

import tannus.ds.Object;

using StringTools;
using Lambda;

@:expose('ArgumentParser')
class ArgParser {
	/* Constructor Function */
	public function new():Void {
		spec = new Map();
	}

/* === Instance Methods === */

	/**
	  * Add an argument to [this] Parser
	  */
	public function addArgument(name:String, ?alias:String, ?consum:Int=1, ?handl:Array<String>->Void):Param {
		var p = new Param(name, alias);
		spec[name] = p;
		if (alias != null)
			spec[alias] = p;
		p.consume = consum;
		p.handle = handl;
		return p;
	}

	/**
	  * Parse an Array of args
	  */
	public function parse(_args : Array<String>):Void {
		var args = _args.copy();
		while (args.length > 0) {
			var arg = args.shift();
			
			if (spec.exists(arg)) {
				var param = spec[arg];
				var pargs:Array<String> = [];
				if (param.consume == -1) {
					while (true) {
						var bit = args.shift();
						if (spec.exists(bit)) {
							args.unshift(bit);
							break;
						}
						else if (bit == null)
							break;
						pargs.push( bit );
					}
				}
				else if (param.consume == -2) {
					while (true) {
						var n = args.shift();
						if (n == null)
							break;
						else pargs.push(n);

					}
				}
				else {
					for (i in 0...param.consume)
						pargs.push(args.shift());
				}
				param.handle( pargs );
			}
			else {
				throw 'Unexpected $arg';
			}
		}
	}

/* === Instance Fields === */

	private var spec : Map<String, Param>;
}

class Param {
	/* Constructor Function */
	public function new(s:String, ?l:String, ?doc:String):Void {
		short = s;
		if (l != null)
			long = l;
		if (doc != null)
			help = doc;
		consume = 1;
	}

/* === Instance Methods === */

	/**
	  * Handle the occurrence of [this] argument
	  */
	public dynamic function handle(args : Array<String>):Void {
		null;
	}

/* === Instance Fields === */
	
	public var short:String;
	public var long:String;
	public var help:String;
	public var consume:Int;
}
