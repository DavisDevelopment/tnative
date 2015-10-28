package tannus.format.cfg;

import tannus.format.cfg.Parser;
import tannus.format.cfg.Parser.Token;

using Lambda;

class Config {
	/* Constructor Function */
	public function new():Void {
		flags = new Array();
		variables = new Map();
		functions = new Map();
	}

/* === Instance Methods === */

	/**
	  * get the value of a variable
	  */
	public function get<T>(name : String):Null<T> {
		return (untyped variables.get(name));
	}

	/**
	  * check for the given flag
	  */
	public function flag(name : String):Bool {
		return (flags.has( name ));
	}

	/**
	  * add a function to [this] Config
	  */
	public function func(name:String, f:Array<Dynamic>->Void):Void {
		functions.set(name, f);
	}

	/**
	  * execute a snippet of CFG code
	  */
	public function execute(code : String):Void {
		parseScript( code );
	}

	/**
	  * parse the config-script
	  */
	private function parseScript(s : String):Void {
		var tokens:Array<Token> = (new Parser().parse( s ));
		for (t in tokens) {
			switch ( t ) {
				/* config flag */
				case TFlag(name):
					flags.push( name );

				/* variable assignment */
				case TVar(name, tval):
					variables.set(name, getValue(tval));

				/* function calls */
				case TCall(name, targs):
					var args:Array<Dynamic> = targs.map(getValue);
					if (functions.exists( name )) {
						(functions.get(name))( args );
					}
					else {
						throw 'NameError: $name is not defined!';
					}

				/* line-break */
				case TStop:
					continue;

				/* anything else */
				default:
					throw 'Error: $t cannot be executed';
			}
		}
	}

	/**
	  * Get the value of a Token
	  */
	private function getValue(t : Token):Dynamic {
		switch ( t ) {
			case TConst( c ):
				switch ( c ) {
					case CNumber(num, _):
						return num;

					case CString( str ):
						return str;

					case CIdent( id ):
						switch (id.toLowerCase()) {
							case 'true', 'false':
								return (id.toLowerCase() == 'true');
							
							case 'null':
								return null;

							default:
								throw 'NameError: $id is not defined';
						}

					case CRef( name ):
						if (variables.exists( name )) {
							return variables.get(name);
						}
						else {
							throw 'NameError: $name is not defined!';
						}

					default:
						throw 'WutTheFuck: Constant $c cannot be converted into a value';
				}

			default:
				throw 'TypeError: $t is not a value!';
		}
	}

/* === Instance Fields === */

	private var flags : Array<String>;
	private var variables : Map<String, Dynamic>;
	public var functions : Map<String, Array<Dynamic> -> Void>;
}
