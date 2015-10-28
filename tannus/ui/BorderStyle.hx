package tannus.ui;

@:enum
abstract BorderStyle (String) from String to String {
	public var Dotted  : String = 'dotted';
	public var Dashed  : String = 'dashed';
	public var Solid   : String = 'solid';
	public var Double  : String = 'double';
	public var Groove  : String = 'groove';
	public var Ridge   : String = 'ridge';
	public var Inset   : String = 'inset';
	public var Outset  : String = 'outset';
}
