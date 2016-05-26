package tannus.nore;

class ORegEx {
	/**
	  * Compile the given String into a CheckFunction
	  */
	public static function compile(sel:String, ?pred:Compiler->Void):CheckFunction {
		var comp:Compiler = new Compiler();
		if (pred != null) {
			pred( comp );
		}
		return comp.compileString( sel );
	}
}
